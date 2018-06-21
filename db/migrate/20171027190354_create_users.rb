class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username, :null => false
      t.string :password
      t.string :ckan_api_key
      t.string :fullname
      t.string :email
      t.string :group
      t.boolean :sysadmin

      t.timestamps
    end
    add_index :users, :username, :unique => true
  end
end
