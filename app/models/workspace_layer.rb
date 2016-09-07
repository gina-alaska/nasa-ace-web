class WorkspaceLayer < ApplicationRecord
  belongs_to :workspace
  belongs_to :layer
  acts_as_list scope: :workspace

  validates :layer_id, uniqueness: { scope: :workspace_id }
end
