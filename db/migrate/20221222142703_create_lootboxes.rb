class CreateLootboxes < ActiveRecord::Migration[6.1]
  def change
    create_table :lootboxes do |t|
      t.belongs_to :black_market_purchase
      t.text :address
      t.integer :state, default: 0, null: false
      t.integer :blockchain_state

      t.timestamps
    end
  end
end
