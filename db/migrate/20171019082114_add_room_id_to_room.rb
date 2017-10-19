class AddRoomIdToRoom < ActiveRecord::Migration[5.1]
  def change
    add_column :rooms, :room_id, :integer
  end
end
