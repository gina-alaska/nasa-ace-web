# frozen_string_literal: true
class Layer < ApplicationRecord
  belongs_to :category
  has_many :view_layers, dependent: :destroy
  has_many :views, through: :view_layers

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

  delegate :maptype, to: :category

  def full_url
    category.postfix.blank? ? url : File.join(url, category.postfix)
  end

  def to_s
    name
  end
end
