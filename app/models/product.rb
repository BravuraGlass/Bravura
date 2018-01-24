class Product < ApplicationRecord
  include AuditableModel

  before_create :set_product_index

  belongs_to :product_type
  belongs_to :room
  has_many :product_sections, :dependent => :destroy
  
  after_update :sync_status
  attr_accessor :audit_user_name

  def self.statuses
    Status.where(:category => Status.categories[:products]).order(:order)
  end
  
  def external_name
    "Task"
  end  

  def to_li
    li = "<ul>"
    li << "<li>Task: #{self.name}</li>"
    li << "<li>Room: #{self.room.try(:name)}</li>"
    li << "<li>Address: #{self.room.try(:job).try(:address)}</li>"
    li << "</ul>" 
    li.html_safe
  end
  
  def name_with_section_count
    sect_count = self.product_sections.size
    "#{self.name} (#{sect_count} section#{sect_count > 1 ? 's' : ''})"
  end  
  
  def room_master?
    if self.room
      if self.room.master?
        return true
      else
        return false
      end
    else
      return false
    end
  end    
  
  def clone_child_data 
    if room_master?     
      self.room.rooms.each do |theroom|
        new_prod = self.deep_clone include: :product_sections
        new_prod.room_id = theroom.id
        new_prod.status = STATUS_DEFAULT[:task] 
        new_prod.product_sections.each_with_index do |sect, idx|
          new_prod.product_sections[idx].status = STATUS_DEFAULT[:material]
        end  
        new_prod.save
      end
    end  
  end 

=begin  
  def self.fix_finished_status
    ids = Product.joins(:product_sections).where("product_sections.status=?","FINISHED").select("products.id").distinct.collect {|prod| prod.id}
    rs = []
    Product.where("id IN (?)", ids).each do |prod|
      if prod.product_sections.size == prod.product_sections.where("status = 'FINISHED'").size
        rs << prod
        prod.update_attribute(:status,"FINISHED")
      end  
    end  
    return rs
    
  end  
=end  

  private
    def sync_status
      unless self.status_before_last_save == self.status
        AuditLog.create(
          user_name: self.audit_user_name,
          details: "updated task's status from #{self.status_before_last_save} to #{self.status}",
          auditable: self
        )
      end 
      
      if self.status == "FINISHED"
        prosects = ProductSection.where("product_id=?", self.id)
        prosects.each do |sect|
          unless sect.status == "FINISHED"
            AuditLog.create(
              user_name: self.audit_user_name,
              details: "updated material's status from #{sect.status} to FINISHED",
              auditable: sect
            )  
          end  
        end
        prosects.update_all("status='FINISHED'")  
         
      end  
      
      old_room_status = self.room.status
      
      if self.room.products.collect {|prod| prod.status}.uniq == ["FINISHED"]
        
        Room.where("id = ?", self.room_id).update_all("status='FINISHED'")
        unless old_room_status == "FINISHED"
          AuditLog.create(
            user_name: self.audit_user_name,
            details: "updated room's status from #{old_room_status} to FINISHED",
            auditable: self.room
          )
        end  
      end  

      if self.status == "Pending"
        Room.where("id = ?", self.room_id).update_all("status='Active'")
        
        unless old_room_status == "Active"
          AuditLog.create(
            user_name: self.audit_user_name,
            details: "updated room's status from #{old_room_status} to Active",
            auditable: self.room
          )
        end 
      end
    end  
  
    # set the index
    def set_product_index
      last_index = Product.where(room: self.room).maximum(:product_index)
      self.product_index = last_index.nil? ? 1 : last_index + 1
    end
end
