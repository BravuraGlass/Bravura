class ChangeDateInt < ActiveRecord::Migration[5.1]
  def change
    remove_column :working_logs, :submit_date
    add_column :working_logs, :submit_date, :integer
  end
end
