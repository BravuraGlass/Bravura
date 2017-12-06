class AddLocationToWl < ActiveRecord::Migration[5.1]
  def change
    add_column :working_logs, :location, :string
  end
end
