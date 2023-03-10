class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :type, null: false
      t.string :name, null: false, index: { unique: true }
      t.json :data, null: false, default: {}

      t.timestamps
    end
  end
end
