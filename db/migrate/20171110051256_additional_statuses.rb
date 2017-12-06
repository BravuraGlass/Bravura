class AdditionalStatuses < ActiveRecord::Migration[5.1]
  def change
    change_column_default :product_sections,:status, from: "", to: "In Fabrication"
    remove_column :products,:status
    add_column :products, :status, :string, default: "Measured"
    add_column :rooms, :status, :string, default: "Active"
  end
end
