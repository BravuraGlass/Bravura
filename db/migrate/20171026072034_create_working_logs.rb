class CreateWorkingLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :working_logs do |t|
      t.datetime :checkin_time
      t.datetime :checkout_time
      t.string :checkin_method
      t.string :checkout_method
      t.string :checkin_date
      t.string :checkout_date
      t.string :latitude
      t.string :longitude
      t.integer :user_id

      t.timestamps
    end
  end
end
