class AddCcanIdToLayer < ActiveRecord::Migration[5.0]
  def change
    add_column :layers, :ccan_id, :string
  end
end
