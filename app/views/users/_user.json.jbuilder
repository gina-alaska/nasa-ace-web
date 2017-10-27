json.extract! user, :id, :user_id, :ckan_api_key, :name, :group, :created_at, :updated_at
json.url user_url(user, format: :json)