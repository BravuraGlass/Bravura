class AddAddressToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :address, :string
  end
end
