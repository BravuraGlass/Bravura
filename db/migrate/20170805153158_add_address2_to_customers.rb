class AddAddress2ToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :address2, :string
  end
end
