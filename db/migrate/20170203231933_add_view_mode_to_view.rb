class AddViewModeToView < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :view_mode, :boolean, default: false
  end
end
