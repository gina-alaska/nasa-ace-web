class RenameWorkspacesToViews < ActiveRecord::Migration[5.0]
  def change
    rename_table :workspaces, :views
  end
end
