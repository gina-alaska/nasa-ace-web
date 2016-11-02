class CreateWorkspaceViews < ActiveRecord::Migration[5.0]
  def change
    create_table :workspace_views do |t|
      t.references :workspace, foreign_key: true
      t.references :view, foreign_key: true

      t.timestamps
    end
  end
end
