class Layer < ApplicationRecord
  belongs_to :category
  has_many :workspace_layers, dependent: :destroy
  has_many :workspaces, through: :workspace_layers

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

  delegate :maptype, to: :category

  def full_url
    File.join(url, category.postfix)
  end

  def to_s
    name
  end
end
