class AddAddressToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :address, :string
  end
end
