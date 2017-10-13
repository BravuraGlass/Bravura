class RemoveImagesFromJobs < ActiveRecord::Migration[5.1]
  def change
    remove_column :jobs, :images, :string
  end
end
