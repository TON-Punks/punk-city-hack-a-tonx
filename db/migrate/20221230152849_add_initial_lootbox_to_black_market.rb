class AddInitialLootboxToBlackMarket < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'punk_lootbox_initial')
      end
    end
  end
end
