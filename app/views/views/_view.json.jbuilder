# frozen_string_literal: true

json.extract! view, :id, :name, :created_at, :updated_at
json.url view_url(view, format: :json)
