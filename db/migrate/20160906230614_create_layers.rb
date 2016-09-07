class CreateLayers < ActiveRecord::Migration[5.0]
  def change
    create_table :layers do |t|
      t.string :name
      t.references :category, foreign_key: true
      t.text :url
      t.string :params
      t.json :style

      t.timestamps
    end
  end
end
