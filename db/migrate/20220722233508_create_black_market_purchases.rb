class CreateBlackMarketPurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :black_market_purchases do |t|
      t.references :black_market_product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :praxis_transaction, null: false, foreign_key: true
      t.json :data, null: false, default: {}

      t.timestamps
    end
  end
end
