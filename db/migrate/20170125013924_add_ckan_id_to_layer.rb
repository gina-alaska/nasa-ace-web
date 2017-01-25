class AddCkanIdToLayer < ActiveRecord::Migration[5.0]
  def change
    add_column :layers, :ckan_id, :string
  end
end
