class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :crypted_password
      t.string :salt
      t.string :first_name
      t.string :last_name
      t.string :phonenumber
      t.string :address
      t.string :type_of_user

      t.timestamps
    end
      add_index :users, :email, unique: true
  end
end
