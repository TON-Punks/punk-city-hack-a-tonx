class AddNewBlackMarketProducts < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'zeya_membership_card', min_price: 2500, current_price: 3000)
        BlackMarketProductStub.create!(slug: 'zeya_nft')
      end
    end
  end
end
