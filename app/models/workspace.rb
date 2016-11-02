class Workspace < ApplicationRecord
  has_many :workspace_views
  has_many :views through: :workspace_views

  def to_s
    name
  end
end
