# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(email: 'admin3@admin.com',password: 'admin',first_name: 'Andriy', last_name: 'Holub',phonenumber: '555 555 5555',address: 'admin address',type_of_user: '0', late_access: true)
