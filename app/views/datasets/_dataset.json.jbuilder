# frozen_string_literal: true

json.extract! dataset, :id, :title, :description, :source, :version, :created_at, :updated_at
json.url dataset_url(dataset, format: :json)
