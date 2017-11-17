class Product < ApplicationRecord
  include AuditableModel

  before_create :set_product_index

  belongs_to :product_type
  belongs_to :room
  has_many :product_sections, :dependent => :destroy
  
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

  private
    # set the index
    def set_product_index
      last_index = Product.where(room: self.room).maximum(:product_index)
      self.product_index = last_index.nil? ? 1 : last_index + 1
    end
end
