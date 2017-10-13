class CreateFabricationOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :fabrication_orders do |t|
      t.string :title
      t.text :description
      t.string :status
      # t.references :job, foreign_key: true, :null => true

      t.timestamps
    end
  end
end
