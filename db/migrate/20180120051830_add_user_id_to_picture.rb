class AddUserIdToPicture < ActiveRecord::Migration[5.1]
  def change
    add_column :pictures, :description, :text
    add_reference :pictures, :user, foreign_key: true
  end
end
