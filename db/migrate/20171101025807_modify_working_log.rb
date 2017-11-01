class ModifyWorkingLog < ActiveRecord::Migration[5.1]
  def change
    rename_column :working_logs, :checkin_time, :submit_time
    rename_column :working_logs, :checkin_date, :submit_date
    remove_column :working_logs, :checkout_time
    remove_column :working_logs, :checkout_date
    rename_column :working_logs, :checkin_method, :submit_method
    rename_column :working_logs, :checkout_method, :checkin_or_checkout
  end
end
