# frozen_string_literal: true
class View < ApplicationRecord
  belongs_to :workspace

  validates :name, uniqueness: true

  has_many :view_layers, -> { order(position: :asc) }, dependent: :destroy
  has_many :layers, through: :view_layers

  BASEMAP_LAYERS = %w( satellite-streets streets outdoors light dark ).freeze

  def to_s
    name
  end

  def duplicate(workspace)
    new_view = workspace.views.new(name: self.name + '-duplicate', center_lat: self.center_lat, center_lng: self.center_lng, zoom: self.zoom, basemap: self.basemap)

    if new_view.save
      active_layers = self.view_layers.where(active: true).collect(&:layer)
      new_view.layers << active_layers

      new_view
    else
      nil
    end
  end 
end
