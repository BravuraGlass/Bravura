class AddAddress2ToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :address2, :string
  end
end
