class FabricationOrder < ApplicationRecord
  include AuditableModel

  belongs_to :job, optional: true
  has_many :rooms, :dependent => :destroy
  has_many :products, :through => :rooms

  accepts_nested_attributes_for :rooms

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
