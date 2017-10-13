json.extract! status_checklist_item, :id, :title, :description, :status_id, :created_at, :updated_at
json.url status_checklist_item_url(status_checklist_item, format: :json)
