class AddNeuropunkProduct < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'neuropunk', min_price: 3000, current_price: 3000)
      end
    end
  end
end
