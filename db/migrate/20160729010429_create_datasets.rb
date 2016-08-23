class CreateDatasets < ActiveRecord::Migration[5.0]
  def change
    create_table :datasets do |t|
      t.string :title
      t.text :description
      t.string :source
      t.string :version

      t.timestamps
    end
  end
end
