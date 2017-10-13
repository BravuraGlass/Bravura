class AddLateAccessToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :late_access, :boolean
  end
end
