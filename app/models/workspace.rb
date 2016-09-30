class Workspace < ApplicationRecord
  has_many :workspace_layers, -> { order(position: :asc) }, dependent: :destroy
  has_many :layers, through: :workspace_layers

  validates :name, uniqueness: true

  BASEMAP_LAYERS = %w( satellite-streets streets outdoors light dark )

  def to_s
    name
  end
end
