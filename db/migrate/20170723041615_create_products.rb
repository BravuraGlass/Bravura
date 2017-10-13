class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.references :product_type, foreign_key: true
      t.string :name
      t.text :description
      t.string :status
      t.string :sku
      t.integer :price
      t.references :room, foreign_key: true

      t.timestamps
    end
  end
end
