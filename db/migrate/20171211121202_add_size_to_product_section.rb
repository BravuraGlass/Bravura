class AddSizeToProductSection < ActiveRecord::Migration[5.1]
  def change
    add_column :product_sections, :size, :string
  end
end
