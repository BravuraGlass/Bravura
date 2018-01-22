json.id file.id
json.job_id file.job_id
json.description file.description
json.file do
  json.url file.data.try(:url)
  json.thumb do
    json.url file.data.try(:thumb).try(:url)
  end
end
json.created_at file.created_at
json.user file.try(:user).try(:full_name)