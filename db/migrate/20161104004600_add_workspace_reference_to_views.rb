class AddWorkspaceReferenceToViews < ActiveRecord::Migration[5.0]
  def change
    add_reference :views, :workspace, foreign_key: true
  end
end
