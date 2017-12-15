class ProductSection < ApplicationRecord
    include AuditableModel

    validate :validate_minimum_edge_size, :if => :status_is_to_temper?

    validates :status, inclusion: { 
      in: Status.where(category: "products").map(&:name),
      message: "%{value} is not a valid status. Available status are #{Status.where(category: "products").map(&:name).join(', ')}" 
    }
    validates :fraction_size_a, inclusion: { 
      in: FRACTION_TYPE,
      message: "%{value} is not a valid fraction type a. Available fraction type are #{FRACTION_TYPE.join(', ')}" 
    }, allow_blank: true

    validates :fraction_size_b, inclusion: { 
      in: FRACTION_TYPE,
      message: "%{value} is not a valid fraction type b. Available fraction type are #{FRACTION_TYPE.join(', ')}" 
    }, allow_blank: true

    validates :edge_type_a, inclusion: {
      in: EdgeType.all.map{|x| "#{x.id}"},
      message: "%{value} is not a valid fraction type b. Available fraction type are #{EdgeType.all.map(&:id).join(', ')}" 
    }, allow_blank: true

    validates :edge_type_b, inclusion: {
      in: EdgeType.all.map{|x| "#{x.id}"},
      message: "%{value} is not a valid fraction type b. Available fraction type are #{EdgeType.all.map(&:id).join(', ')}" 
    }, allow_blank: true

    validates :edge_type_c, inclusion: {
      in: EdgeType.all.map{|x| "#{x.id}"},
      message: "%{value} is not a valid fraction type b. Available fraction type are #{EdgeType.all.map(&:id).join(', ')}" 
    }, allow_blank: true

    validates :edge_type_d, inclusion: {
      in: EdgeType.all.map{|x| "#{x.id}"},
      message: "%{value} is not a valid fraction type b. Available fraction type are #{EdgeType.all.map(&:id).join(', ')}" 
    }, allow_blank: true
    
    belongs_to :product
    after_update :sync_status
    attr_accessor :audit_user_name

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
      name_size << "#{self.size_a}#{self.fraction_size_a}" if self.size_a.present? || self.fraction_size_a.present? 
      name_size << "x#{self.size_b}#{self.fraction_size_b}" if self.size_b.present? || self.fraction_size_b.present?
      name_size
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
