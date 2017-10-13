class ChangeStatusOnJobs < ActiveRecord::Migration[5.1]
  def change
    change_column :jobs, :status, :string
  end
end
