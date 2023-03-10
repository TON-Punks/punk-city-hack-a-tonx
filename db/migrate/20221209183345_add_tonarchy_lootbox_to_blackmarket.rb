class AddTonarchyLootboxToBlackmarket < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'tonarchy_lootbox', min_price: 499, current_price: 499)
      end
    end
  end
end
