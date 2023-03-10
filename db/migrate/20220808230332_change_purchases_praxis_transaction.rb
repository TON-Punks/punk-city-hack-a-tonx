class ChangePurchasesPraxisTransaction < ActiveRecord::Migration[6.1]
  def change
    change_column_null :black_market_purchases, :praxis_transaction_id, true
  end
end
