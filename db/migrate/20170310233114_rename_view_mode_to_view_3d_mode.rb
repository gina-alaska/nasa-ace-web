class RenameViewModeToView3dMode < ActiveRecord::Migration[5.0]
  def change
    rename_column :views, :view_mode, :view_3d_mode
  end
end
