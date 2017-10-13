json.extract! product, :id, :product_type_id, :name, :description, :status, :sku, :price, :created_at, :updated_at
json.url product_url(product, format: :json)
