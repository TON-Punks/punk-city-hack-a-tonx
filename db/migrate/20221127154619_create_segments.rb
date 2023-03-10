class CreateSegments < ActiveRecord::Migration[6.1]
  def change
    create_table :segments do |t|
      t.string :name, null: false
      t.string :type, null: false

      t.timestamps
    end

    add_index :segments, %i[name type], unique: true
  end
end
