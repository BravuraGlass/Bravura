class AddJobToFabricationOrders < ActiveRecord::Migration[5.1]
  def change
    add_reference :fabrication_orders, :job, foreign_key: true
  end
end
