# frozen_string_literal: true

json.extract! view_layer, :id, :view_id, :layer_id, :position, :created_at, :updated_at
json.url view_layer_url(view_layer, format: :json)
