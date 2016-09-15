class AddPresenterIdToWorkspace < ActiveRecord::Migration[5.0]
  def change
    add_column :workspaces, :presenter_id, :string
  end
end
