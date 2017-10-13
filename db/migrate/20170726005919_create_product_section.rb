class CreateProductSection < ActiveRecord::Migration[5.1]
  def change
    create_table :product_sections do |t|
      t.references :product, foreign_key: true
      t.string :status
      t.string :name
    end
  end
end
