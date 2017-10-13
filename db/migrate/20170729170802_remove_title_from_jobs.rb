class RemoveTitleFromJobs < ActiveRecord::Migration[5.1]
  def change
    remove_column :jobs, :title, :string
  end
end
