# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user1 = User.create(email: 'admin@admin.com',password: 'admin',first_name: 'Kevin', last_name: 'Admin',phonenumber: '555 555 5555',address: 'admin address',type_of_user: '0', always_access: true)
user2 = User.create(email: 'admin3@admin.com',password: 'admin',first_name: 'Admin', last_name: 'Bravura',phonenumber: '555 555 5555',address: 'admin address',type_of_user: '0', always_access: true)
user3 = User.create(email: 'employee@employee.com',password: 'employee',first_name: 'Employee', last_name: 'Superstar',phonenumber: '555 555 5555',address: 'admin address',type_of_user: '2', always_access: false)
user4 = User.create(email: 'field1@field.com',password: 'employee',first_name: 'Albert', last_name: '55',phonenumber: '555 555 5555',address: 'worker address',type_of_user: '3', always_access: true)
user5 = User.create(email: 'field2@field.com.com',password: 'employee',first_name: 'Dany', last_name: '7',phonenumber: '555 555 5555',address: 'worker address',type_of_user: '3', always_access: true)

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
Status.create(category: "products",name: "To Temper", order: 12)
Status.create(category: "products",name: "FINISHED", order: 19)

customer1 = Customer.create(contact_firstname: "Satya", contact_lastname: "Nadella", email: "satya@microsoft.com", company_name: "Microsoft")
customer2 = Customer.create(contact_firstname: "Yukihiro", contact_lastname: "Mastsumoto", email: "matz@ruby.org", company_name: "Ruby")


time_now = Time.now
start = (time_now - 3.hours).to_i

Location.create(user: user1 , latitude: 40.7233, longitude: -74.003)
Location.create(user: user2, latitude: 40.852, longitude: -74.0753)
Location.create(user: user3, latitude: 40.7233, longitude: -74.003, created_at: Time.at(rand(time_now.to_i - start)) + start)
Location.create(user: user1, latitude: 40.6488, longitude: -73.9464, created_at: Time.at(rand(time_now.to_i - start)) + start)
Location.create(user: user2, latitude: 40.6937, longitude: -73.988)
Location.create(user: user3, latitude: 40.6715, longitude: -73.9476)


employee1 = Employee.create(first_name: "Edison", last_name: "Cavani", email_address: "edison@psg.com")
employee2 = Employee.create(first_name: "Leroy", last_name: "Sane", email_address: "leroy@mancity.com")

["Mirror","Window","Table"].each do |ptype|
  ProductType.create(name: ptype)
end

["PL", "BV", "PL45", "SEAM"].each do |etype|
  EdgeType.create(name: etype)
end


tomorrow = Date.today+1.days

job1 = Job.create({customer: customer1, price: 30000, deposit: nil, priority: nil, status: "Proposal", appointment: "#{tomorrow} 17:00:00", installer: employee1, salesman: employee2, duration: nil, duedate: nil, paid: false, active: true, latitude: 40.7233, longitude: -74.003, address: "SoHo, New York, NY, USA", address2: "", notes: "", confirmed_appointment: false, balance: 30000, appointment_end: "#{tomorrow} 18:00:00"})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to Active", auditable_type: "Room", auditable_id: job1.id})

job2 = Job.create({customer: customer2, price: 40000, deposit: nil, priority: nil, status: "Proposal", appointment: "#{tomorrow} 19:00:00", installer: employee1, salesman: employee2, duration: nil, duedate: nil, paid: false, active: true, latitude: 40.6199, longitude: -73.9427, address: "Avenue M, Brooklyn, NY, USA", address2: "", notes: "", confirmed_appointment: false, balance: 40000, appointment_end: "#{tomorrow} 20:00:00"})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to Proposal", auditable_type: "Job", auditable_id: job2.id})

order1 = FabricationOrder.create({title: "SoHo, New York, NY, USA", description: "Fabrication order for Job on SoHo, New York, NY, USA", status: "In Progress", job: job1})
order2 = FabricationOrder.create({title: "Avenue M, Brooklyn, NY, USA", description: "Fabrication order for Job on Avenue M, Brooklyn, NY, USA", status: "In Progress", job: job2})

room1 = Room.create({name: "101", description: nil, fabrication_order: order1, master: nil, room_id: nil, status: "Active"})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to Active", auditable_type: "Room", auditable_id: room1.id})

room2 = Room.create({name: "102", description: nil, fabrication_order: order2, master: nil, room_id: nil, status: "Active"})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to Active", auditable_type: "Room", auditable_id: room2.id})


product1 = Product.create({product_type: ProductType.first, name: "Glass Board", description: nil, sku: nil, price: nil, room: room1, product_index: 1, status: "Measured"})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to Measured", auditable_type: "Product", auditable_id: product1.id})

product2 = Product.create({product_type: ProductType.first, name: "Wall Mirror", description: nil, sku: nil, price: nil, room: room2, product_index: 1, status: "Measured"})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to Measured", auditable_type: "Product", auditable_id: product2.id})

edge_type_pl = EdgeType.first

section1 = ProductSection.create({product: product1, status: "In Fabrication", name: "1-101-1", section_index: 1, size_a: 200, size_b: 500, fraction_size_a: "", fraction_size_b: "", edge_type_a: edge_type_pl, edge_type_b: edge_type_pl, edge_type_c: edge_type_pl, edge_type_d: edge_type_pl, size_type: 'box'})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to In Fabrication", auditable_type: "ProductSection", auditable_id: section1.id})

section2 = ProductSection.create({product: product2, status: "To Temper", name: "2-102-1-1", section_index: 1, size_a: 200, size_b: 300, fraction_size_a: "", fraction_size_b: "", edge_type_a: edge_type_pl, edge_type_b: edge_type_pl, edge_type_c: edge_type_pl, edge_type_d: edge_type_pl, size_type: 'box'})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to In Fabrication", auditable_type: "ProductSection", auditable_id: section2.id})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: nil, user_agent: nil, details: "updated material's status from In Fabrication to To Temper", auditable_type: "ProductSection", auditable_id: section2.id})

section3 = ProductSection.create({product: product2, status: "Ordered", name: "2-102-1-2", section_index: 2, size_a: 400, size_b: 600, fraction_size_a: "", fraction_size_b: "", edge_type_a: edge_type_pl, edge_type_b: edge_type_pl, edge_type_c: edge_type_pl, edge_type_d: edge_type_pl, size_type: 'box'})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: "::1", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36", details: "Newly created data, set status to In Fabrication", auditable_type: "ProductSection", auditable_id: section3.id})
AuditLog.create({user_name: "Kevin Admin", where: nil, ip: nil, user_agent: nil, details: "updated material's status from In Fabrication to Ordered", auditable_type: "ProductSection", auditable_id: section3.id})