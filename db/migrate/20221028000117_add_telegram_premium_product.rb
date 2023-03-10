class AddTelegramPremiumProduct < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'telegram_premium', min_price: 0, current_price: 0)
      end
    end
  end
end
