class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :user_id
      t.string :ckan_api_key
      t.string :name
      t.string :group

      t.timestamps
    end
  end
end
