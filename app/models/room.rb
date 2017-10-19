class Room < ApplicationRecord
  include AuditableModel

  belongs_to :fabrication_order

  has_many :products, :dependent => :destroy
  belongs_to :room, class_name: "Room", optional: true
  has_many :rooms, class_name: "Room"
  
  validates_uniqueness_of :master, uniqueness: true, allow_blank: true
  
  def master_clone
    if self.master.blank?
      return false
    else
      new_room = self.deep_clone include: { products: :product_sections }
      new_room.name = self.nextname
      new_room.master = ""
      new_room.room_id = self.id
      
      if new_room.save
        return true
      else
        return false
      end    
    end    
  end  
  
  def nextname
    last_room = self.fabrication_order.rooms.order("name ASC").last
    if last_room.name.blank?
      "new room"
    elsif last_room.name.to_i > 0
      last_room.name.to_i + 1
    else
      "copy of #{self.name}"
    end    
  end  
  
end
