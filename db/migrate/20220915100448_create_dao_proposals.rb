class CreateDaoProposals < ActiveRecord::Migration[6.1]
  def change
    create_table :dao_proposals do |t|
      t.text :name
      t.text :description
      t.belongs_to :punk, null: false, foreign_key: true
      t.timestamp :expires_at
      t.integer :state, default: 0, null: false

      t.timestamps
    end
  end
end
