class AddActiveFieldToWorkspaceLayers < ActiveRecord::Migration[5.0]
  def change
    add_column :workspace_layers, :active, :boolean, default: false
  end
end
