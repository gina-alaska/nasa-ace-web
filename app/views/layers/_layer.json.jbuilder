json.extract! layer, :id, :name, :category_id, :url, :params, :style, :created_at, :updated_at
json.url layer_url(layer, format: :json)
