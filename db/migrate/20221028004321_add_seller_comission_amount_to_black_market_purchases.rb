class AddSellerComissionAmountToBlackMarketPurchases < ActiveRecord::Migration[6.1]
  def change
    add_column :black_market_purchases, :seller_comission_amount, :decimal, precision: 16, scale: 10, null: false, default: 0
  end
end
