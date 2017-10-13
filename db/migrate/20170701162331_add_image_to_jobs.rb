class AddImageToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :image, :string
  end
end
