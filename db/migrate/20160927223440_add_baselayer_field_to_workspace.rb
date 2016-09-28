class AddBaselayerFieldToWorkspace < ActiveRecord::Migration[5.0]
  def change
    add_column :workspaces, :basemap, :string
  end
end
