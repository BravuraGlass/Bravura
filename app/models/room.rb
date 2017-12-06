class Room < ApplicationRecord
  include AuditableModel

  belongs_to :fabrication_order

  has_many :products, :dependent => :destroy
  belongs_to :room, class_name: "Room", optional: true
  has_many :rooms, class_name: "Room"
  
  after_update :sync_status
  after_update :update_product_section_names, if: :name_was_updated?

  
  validates_uniqueness_of :master, uniqueness: true, allow_blank: true
  validates_presence_of :name
  validates_uniqueness_of :name, uniqueness: true, allow_blank: true, scope: :fabrication_order_id

  def self.statuses
    Status.where(:category => Status.categories[:rooms]).order(:order)
  end
  
  def master_clone(new_room_name)
    if self.master.blank?
      return {success: false, error_messages: ["Master can't be blank"] }
    else
      new_room = self.deep_clone include: { products: :product_sections }
      new_room.name = new_room_name
      new_room.master = ""
      new_room.status = STATUS_DEFAULT[:room]
      new_room.room_id = self.id
      
      new_room.products.each_with_index do |prod, idx|
        new_room.products[idx].status = STATUS_DEFAULT[:task]
        prod.product_sections.each_with_index do |sect, idx2|
          splitname = sect.name.split("-") 
          if splitname.size == 3
            newname = "#{splitname[0]}-#{new_room.name}-#{splitname[2]}"
          else
            newname = sect.name
          end    
          new_room.products[idx].product_sections[idx2].name = newname  
          new_room.products[idx].product_sections[idx2].status = STATUS_DEFAULT[:material]  
        end  
      end   
      
      if new_room.save
        return {success: true, room: new_room}
      else
        return {success: false, error_messages: new_room.errors.full_messages}
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
    last_room = self.fabrication_order.sorting_rooms.last
    name_rev = last_room.name.reverse 
    
    if last_room.name.blank?
      "new room"
    elsif last_room.name.is_int?
      last_room.name.to_i + 1
    elsif name_rev.size > 1
      if ((name_rev[0].is_int? == false and name_rev[1].is_int?) || 
           !!last_room.name.match(/(^.*[^0-9])([\s0-9]*?[\d]$)/) )
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

  private
    def name_was_updated?
      self.saved_change_to_attribute? :name
    end

    def update_product_section_names
      job_id = self.fabrication_order.job_id
      old_room_name, new_room_name = self.saved_changes["name"][0], self.saved_changes["name"][1]

      sections = ProductSection.where(
        ["name LIKE (?) AND product_id IN (?)", "#{job_id}-#{old_room_name}-%", self.product_ids]
      )
      sections.each do |section|
        new_name = section.name.gsub("#{job_id}-#{old_room_name}-", "#{job_id}-#{new_room_name}-")
        section.name = new_name
        section.save
      end
    end
  
  
  def sync_status
    if self.status == "FINISHED"
      Product.where("room_id=?", self.id).update_all("status='FINISHED'")
      ProductSection.where("products.room_id=?", self.id).joins(:product).update_all("product_sections.status='FINISHED'")
    elsif self.status == "Not Active"
      Product.where("room_id=?", self.id).update_all("status='N/A'")
      ProductSection.where("products.room_id=?", self.id).joins(:product).update_all("product_sections.status='N/A'")
    elsif attribute_before_last_save("status") == "Not Active" && self.status == "Active"
      Product.where("room_id=?", self.id).update_all("status='In Fabrication'")
      ProductSection.where("products.room_id=?", self.id).joins(:product).update_all("product_sections.status='Measured'")
    end  
  end  
  
end
