class AddMasterToRoom < ActiveRecord::Migration[5.1]
  def change
    add_column :rooms, :master, :string
  end
end
