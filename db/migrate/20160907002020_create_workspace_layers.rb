class CreateWorkspaceLayers < ActiveRecord::Migration[5.0]
  def change
    create_table :workspace_layers do |t|
      t.references :workspace, foreign_key: true
      t.references :layer, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
