class AddDataToAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :assets, :data, :string
    add_reference :assets, :user, foreign_key: true
  end
end
