class AddSectionIndexToProductSections < ActiveRecord::Migration[5.1]
  def change
    add_column :product_sections, :section_index, :int
  end
end
