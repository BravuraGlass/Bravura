class AddLatitudeAndLongitudToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :latitude, :float
    add_column :tasks, :longitude, :float
  end
end
