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
end
