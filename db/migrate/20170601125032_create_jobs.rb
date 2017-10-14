class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.belongs_to :customer, foreign_key: true
      t.decimal :price
      t.decimal :deposit
      t.string :priority
      t.column :status, :integer, default: 0
      t.datetime :appointment
      t.belongs_to :installer, index: true
      t.belongs_to :salesman, index: true
      t.string :duration
      t.datetime :duedate
      t.boolean :paid
      t.boolean :active, default: true

      t.timestamps
    end

    add_foreign_key :jobs, :employees, column: :salesman_id
    add_foreign_key :jobs, :employees, column: :installer_id
  end
end
