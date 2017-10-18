# frozen_string_literal: true

json.array! @datasets, partial: 'datasets/dataset', as: :dataset
