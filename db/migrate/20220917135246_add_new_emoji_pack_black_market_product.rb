class AddNewEmojiPackBlackMarketProduct < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'emoji_pack', min_price: 1000, current_price: 1000)
      end
    end
  end
end
