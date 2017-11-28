class AddAppointmentEndToJob < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :appointment_end, :datetime
  end
end
