json.extract! job, :id, :customer, :notes, :details, :price, :priority, :created_at, :updated_at
json.url job_url(job, format: :json)
