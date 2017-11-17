class AllAccess < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :late_access, :string
    add_column :users, :always_access, :boolean, default: false
  end
end
