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

  private
    # set the index
    def set_product_index
      last_index = Product.where(room: self.room).maximum(:product_index)
      self.product_index = last_index.nil? ? 1 : last_index + 1
    end
end
