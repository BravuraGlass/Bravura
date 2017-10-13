class AddImagesToJobs < ActiveRecord::Migration[5.1]
  def change
    remove_column :jobs, :image, :string
    add_column :jobs, :images, :text, :null => true
  end
end
