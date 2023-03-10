class CreateMissions < ActiveRecord::Migration[6.1]
  def change
    create_table :missions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false
      t.jsonb :data, null: false, default: {}
      t.integer :state, null: false

      t.timestamps
    end
  end
end
