class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.datetime :duedate
      t.text :description

      t.timestamps
    end
  end
end
