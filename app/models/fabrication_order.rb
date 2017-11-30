class FabricationOrder < ApplicationRecord
  include AuditableModel

  belongs_to :job, optional: true
  has_many :rooms, :dependent => :destroy
  has_many :products, :through => :rooms
  has_many :product_sections, :through => :products

  accepts_nested_attributes_for :rooms

  def self.statuses
    Status.where(:category => Status.categories[:fabrication_orders]).order(:order)
  end

  # collect all audit logs of rooms, products, product sections
  def all_audit_logs
    room_ids = self.room_ids
    room_logs = AuditLog.where(auditable_type: "Room", auditable_id: room_ids)

    product_ids = Product.select("id").where(room_id: room_ids).collect(&:id)
    product_logs = AuditLog.where(auditable_type: "Product", :auditable_id => product_ids)

    product_section_ids = ProductSection.select("id").where(product_id: product_ids).collect(&:id)
    product_section_logs = AuditLog.where(auditable_type: "ProductSection", :auditable_id =>  product_section_ids)

    (room_logs + product_logs + product_section_logs).sort {|x,y| y.created_at <=> x.created_at }
  end

  # loop through rooms and products to get the list of segments
  def sections
    sections = []
    rooms.each do |room|
      room.products.each do |product|
        product.product_sections.each do |section|
          sections << section
        end
      end
    end
    sections
  end
  
  def sorting_rooms
    rooms_num = []
    rooms_str = []
    self.rooms.each do |room|
      if room.name.to_i == 0
        rooms_str << room
      elsif
        rooms_num << room
      end    
    end  
    
    return (rooms_num.sort_by {|room| room.name.to_i}) + (rooms_str.sort_by {|room| room.name.to_s})
  end  

  def sections_to_json
    sections.to_json
  end
  
  def address
    return self.title.blank? ? self.job.address : self.title
  end  

  def sections_status
    ready = 0
    sections.each do |section|
      # a status with order greater than 10 means ready
      status = Status.where(name: section.status, category: Status.categories[:products]).first
      ready += 1 if (status && status.order >= 10) || section.status == 'Ready'
    end
    { total: sections.size, ready: ready, done: sections.size == ready }
  end
end
