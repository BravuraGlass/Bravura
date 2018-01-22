class CreateAssets < ActiveRecord::Migration[5.1]
  def change
    create_table :assets do |t|
      t.string :type
      t.integer :owner_id
      t.string :owner_type
      t.string :data_file_name
      t.string :data_content_type
      t.integer :data_file_size
      t.datetime :data_updated_at
      t.integer :order
      t.text :description

      t.timestamps
    end
  end
end
