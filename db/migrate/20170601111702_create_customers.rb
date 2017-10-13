class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :contact_firstname
      t.string :contact_lastname
      t.string :company_name
      t.string :email
      t.string :email2
      t.string :address
      t.string :phone_number
      t.string :phone_number2
      t.string :fax
      t.text :notes

      t.timestamps
    end
  end
end
