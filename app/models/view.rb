# frozen_string_literal: true

class View < ApplicationRecord
  belongs_to :workspace

  validates :name, uniqueness: true

  has_many :view_layers, -> { order(position: :asc) }, dependent: :destroy
  has_many :layers, through: :view_layers

  BASEMAP_LAYERS = %w(satellite-streets streets outdoors light dark).freeze

  def to_s
    name
  end

  def duplicate
    new_view = workspace.views.create(name: name + '-duplicate', center_lat: center_lat, center_lng: center_lng, zoom: zoom, basemap: basemap, view_3d_mode: view_3d_mode)

    new_view.layers = view_layers.collect(&:layer)

    new_view.save

    new_view
  end
end
