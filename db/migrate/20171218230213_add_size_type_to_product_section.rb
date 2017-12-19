class AddSizeTypeToProductSection < ActiveRecord::Migration[5.1]
  def change
    add_column :product_sections, :size_type, :string
  end
end
