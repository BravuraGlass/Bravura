json.extract! customer, :id, :contact_firstname, :contact_lastname, :company_name, :email, :email2, :address, :phone_number, :phone_number2, :fax, :notes, :address2, :created_at, :updated_at
json.url customer_url(customer, format: :json)
