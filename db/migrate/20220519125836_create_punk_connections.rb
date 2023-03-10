class CreatePunkConnections < ActiveRecord::Migration[6.1]
  def change
    create_table :punk_connections do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :punk, null: false, foreign_key: true
      t.integer :state, default: 0, null: false

      t.timestamps
    end
  end
end
