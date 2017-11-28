# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(email: 'admin@admin.com',password: 'admin',first_name: 'Admin', last_name: 'Bravura',phonenumber: '555 555 5555',address: 'admin address',type_of_user: '0', always_access: true)
User.create(email: 'admin3@admin.com',password: 'admin',first_name: 'Admin', last_name: 'Bravura3',phonenumber: '555 555 5555',address: 'admin address',type_of_user: '0', always_access: true)
User.create(email: 'employee@employee.com',password: 'employee',first_name: 'Employee', last_name: 'Bravura',phonenumber: '555 555 5555',address: 'admin address',type_of_user: '1', always_access: false)

Status.create(category: "jobs",name: "Estimate", order: 1)
Status.create(category: "jobs",name: "Proposal", order: 2)
Status.create(category: "jobs",name: "Measure", order: 3)
Status.create(category: "jobs",name: "To Bill", order: 10)

Status.create(category: "fabrication_orders",name: "In Progress", order: 1)
Status.create(category: "fabrication_orders",name: "GO AHEAD", order: 2)

Status.create(category: "rooms",name: "Not Active", order: 1)
Status.create(category: "rooms",name: "Active", order: 2)
Status.create(category: "rooms",name: "LOCKED", order: 3)
Status.create(category: "rooms",name: "FINISHED", order: 4)

Status.create(category: "tasks",name: "Measured", order: 1)
Status.create(category: "tasks",name: "MLDG INS", order: 2)
Status.create(category: "tasks",name: "N/A", order: 3)
Status.create(category: "tasks",name: "FINISHED", order: 4)
Status.create(category: "tasks",name: "Pending", order: 3)

Status.create(category: "products",name: "In Fabrication", order: 1)
Status.create(category: "products",name: "@ Skyland", order: 8)
Status.create(category: "products",name: "Ordered", order: 9)
Status.create(category: "products",name: "Installed", order: 10)
Status.create(category: "products",name: "N/A", order: 11)
Status.create(category: "products",name: "FINISHED", order: 19)

Customer.create(contact_firstname: "Satya", contact_lastname: "Nadella", email: "satya@microsoft.com", company_name: "Microsoft")
Customer.create(contact_firstname: "Yukihiro", contact_lastname: "Mastsumoto", email: "matz@ruby.org", company_name: "Ruby")

Employee.create(first_name: "Edison", last_name: "Cavani", email_address: "edison@psg.com")
Employee.create(first_name: "Leroy", last_name: "Sane", email_address: "leroy@mancity.com")

["Mirror","Window","Table"].each do |ptype|
  ProductType.create(name: ptype)
end  