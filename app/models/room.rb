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
  
  def master?
    return (self.master and self.rooms.count > 0) ? true : false
  end  
    
  def name_with_master
    if self.master?
      "#{self.name} - #{self.master}"
    else
      "#{self.name}"
    end    
  end  
  
  def nextname
    last_room = self.fabrication_order.rooms.order("name ASC").last
    name_rev = last_room.name.reverse 
    
    if last_room.name.blank?
      "new room"
    elsif last_room.name.is_int?
      last_room.name.to_i + 1
    elsif name_rev.size > 1
      if name_rev[0].is_int? == false and name_rev[1].is_int?
        arr_name_rev = name_rev.split("")
        arr_name_rev[0] = arr_name_rev[0].next
        return arr_name_rev.join("").reverse
      else
        "copy of #{self.name}"  
      end   
    elsif last_room.name.size == 1    
      return last_room.name.next 
    else
      "copy of #{self.name}"
    end    
  end  
  
end
