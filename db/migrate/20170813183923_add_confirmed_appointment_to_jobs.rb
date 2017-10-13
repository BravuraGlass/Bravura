class AddConfirmedAppointmentToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :confirmed_appointment, :boolean
  end
end
