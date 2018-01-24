class ProductSection < ApplicationRecord
    include AuditableModel

=begin
    validate :validate_minimum_edge_size, :if => :status_is_to_temper?
    validates :size_a, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 9999}, allow_blank: true
    validates :size_b, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 9999}, allow_blank: true

    validates :size_type, inclusion: { in: SIZE_TYPE, message: "Size Type not valid."}
    
    validates :status, inclusion: { 
      in: Status.where(category: "products").map(&:name),
      message: "%{value} is not a valid status." 
    }
    validates :fraction_size_a, inclusion: { 
      in: FRACTION_TYPE,
      message: "Fraction size type A is not valid." 
    }, allow_blank: true

    validates :fraction_size_b, inclusion: { 
      in: FRACTION_TYPE,
      message: "Fraction size type B is not valid." 
    }, allow_blank: true
  
    
    validates_presence_of :edge_type_a
    validates_presence_of :edge_type_b,  unless: :is_oval?
    validates_presence_of :edge_type_c,  unless: :is_oval?
    validates_presence_of :edge_type_d,  unless: :is_oval?
=end  
    belongs_to :product
    belongs_to :edge_type_a, class_name: 'EdgeType', foreign_key: 'edge_type_a_id', optional: true
    belongs_to :edge_type_b, class_name: 'EdgeType', foreign_key: 'edge_type_b_id', optional: true
    belongs_to :edge_type_c, class_name: 'EdgeType', foreign_key: 'edge_type_c_id', optional: true
    belongs_to :edge_type_d, class_name: 'EdgeType', foreign_key: 'edge_type_d_id', optional: true
    after_update :sync_status
    before_save :set_same_size, if: :same_size_ids_present?
    attr_accessor :audit_user_name, :set_pl, :same_size_ids

    after_initialize :init

  def init
    seam = EdgeType.find_or_create_by(name: "SEAM") rescue nil
    self.edge_type_a ||= seam
    self.edge_type_b ||= seam
    self.edge_type_c ||= seam
    self.edge_type_d ||= seam
  end

  def to_li
    li = "<ul>"
    li << "<li>Material: #{self.name_size}</li>"
    li << "<li>Task: #{self.product.try(:name)}</li>"
    li << "<li>Room: #{self.product.try(:room).try(:name)}</li>"
    li << "<li>Address: #{self.product.try(:room).try(:job).try(:address)}</li>"
    li << "</ul>" 
    li.html_safe
  end
  
  def external_name
    "Material"
  end  

  def set_same_size
      if self.valid?
        same_sizes.each do |ps|
          next if ps.id == self.id
          ps.update_attributes(
            size_a: self.size_a,
            size_b: self.size_b,
            fraction_size_a: self.fraction_size_a,
            fraction_size_b: self.fraction_size_b,
            edge_type_a_id: self.edge_type_a_id,
            size_type: self.size_type,
            edge_type_b_id: self.edge_type_b_id,
            edge_type_c_id: self.edge_type_c_id,
            edge_type_d_id: self.edge_type_d_id
          )
        end
      end
    end

    def same_size_ids_present?
      self.same_size_ids.present?
    end

    def same_sizes
      ProductSection.where(id: self.same_size_ids) rescue []
    end

    def same_size_names
      if self.same_size_ids.present?
        same_sizes.map(&:name).join(', ') rescue self.name
      end
    end

    def is_oval?
      self.size_type == "oval"  
    end

    def as_json(options)
      super(include: {
                        product: {
                          only: [:name, :product_name, :status, :room, :product_index],
                          include: {
                            room: { only: [:name] }
                          }
                        }
                    })
    end

    def validate_minimum_edge_size
      unless self.minimum_edge_size
        errors.add :status, "Size and Edge types must be entered before the material to be tempered."
      end
    end

    def minimum_edge_size
      self.size_a.present? && self.size_b.present? && 
        self.edge_type_a.present? && self.edge_type_b.present? && self.edge_type_c.present? && self.edge_type_d.present? 
    end

    def name_size
      name_size = self.name
      name_size << ", size: " if self.size_a.present? || self.size_b.present?
      name_size << self.size
      name_size << " (#{self.size_type})" if self.size_type.present?
      name_size
    end

    def size
      size = "#{self.size_a} #{self.fraction_size_a}" if self.size_a.present? || self.fraction_size_a.present? 
      size << " x #{self.size_b} #{self.fraction_size_b}" if self.size_b.present? || self.fraction_size_b.present?
      size.to_s
    end

    def status_is_to_temper?
      self.status == "To Temper"
    end
    
    private
    def sync_status
      unless self.status_before_last_save == self.status
        AuditLog.create(
          user_name: self.audit_user_name,
          details: "updated material's status from #{self.status_before_last_save} to #{self.status}",
          auditable: self
        )
      end 
      
      old_product_status = self.product.status
      old_room_status = self.product.room.status
      
      if self.status == 'FINISHED'
        if self.product.product_sections.collect {|sect| sect.status}.uniq == ["FINISHED"]
          Product.where("id = ?", self.product_id).update_all("status='FINISHED'")
          unless old_product_status == "FINISHED"
            AuditLog.create(
              user_name: self.audit_user_name,
              details: "updated material's status from #{old_product_status} to FINISHED",
              auditable: self.product
            )
          end  
          
          if self.product.room.products.collect {|prod| prod.status}.uniq == ["FINISHED"]
            Room.where("id = ?", self.product.room_id).update_all("status='FINISHED'")
            unless old_room_status == "FINISHED"
              AuditLog.create(
                user_name: self.audit_user_name,
                details: "updated room's status from #{old_room_status} to FINISHED",
                auditable: self.product.room
              )
            end  
          end  
        end
      elsif self.status != 'FINISHED' && attribute_before_last_save("status") == "FINISHED"
        Product.where("id = ?", self.product_id).update_all("status='Pending'")
        unless old_product_status == "Pending"
          AuditLog.create(
            user_name: self.audit_user_name,
            details: "updated material's status from #{old_product_status} to Pending",
            auditable: self.product
          )
        end  
        
        unless old_room_status == "Active"
          Room.where("id = ?", self.product.room_id).update_all("status='Active'")
          AuditLog.create(
            user_name: self.audit_user_name,
            details: "updated material's status from #{old_room_status} to Active",
            auditable: self.product.room
          )
        end  
      end    
    end  
    
    

=begin    
    def self.fix_finished_status
      Product.where("status = ?","FINISHED").each do |pro|
        prod.product_sections.each do |sect|
          sect.update_attribute(:status,"FINISHED")
        end  
      end  
    end
=end      
end
