class AddStateToBlackMarketPurchases < ActiveRecord::Migration[6.1]
  class BlackMarketPurchaseStub < ApplicationRecord
    self.table_name = :black_market_purchases
  end

  def change
    change_table :black_market_purchases, bulk: true do |t|
      t.integer :state, null: false, default: 0
      t.integer :payment_method, null: false, default: 0
      t.decimal :payment_amount, precision: 16, scale: 10, null: false, default: 0
      t.references :seller_user, null: true
    end

    reversible do |dir|
      dir.up do
        BlackMarketPurchaseStub.update_all(state: 3)
      end
    end
  end
end
