class AddCategoryToStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :statuses, :category, :integer
  end
end
