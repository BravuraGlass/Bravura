json.extract! job, :id, :customer, :notes, :address, :price, :priority, :created_at, :updated_at
json.url job_url(job, format: :json)
