class RenameWorkspaceLayersToViewLayers < ActiveRecord::Migration[5.0]
  def change
    rename_table :workspace_layers, :view_layers
    rename_column :view_layers, :workspace_id, :view_id
  end
end
