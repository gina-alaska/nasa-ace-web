class AddLocationInfoToWorkspace < ActiveRecord::Migration[5.0]
  def change
    add_column :workspaces, :center_lat, :decimal, precision: 12, scale: 8
    add_column :workspaces, :center_lng, :decimal, precision: 12, scale: 8
    add_column :workspaces, :zoom, :decimal, precision: 12, scale: 8
  end
end
