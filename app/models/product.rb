class Product < ApplicationRecord
  include AuditableModel

  before_create :set_product_index

  belongs_to :product_type
  belongs_to :room
  has_many :product_sections, :dependent => :destroy

  private
    # set the index
    def set_product_index
      last_index = Product.where(room: self.room).maximum(:product_index)
      self.product_index = last_index.nil? ? 1 : last_index + 1
    end
end
