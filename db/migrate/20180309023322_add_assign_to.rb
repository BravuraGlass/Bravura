class AddAssignTo < ActiveRecord::Migration[5.1]
  def up
    add_column :jobs, :assign_to_id, :integer
  end
  
  def down
    remove_column :jobs, :assign_to_id
  end  
end
