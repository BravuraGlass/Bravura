class AddProductIndexToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :product_index, :integer
  end
end
