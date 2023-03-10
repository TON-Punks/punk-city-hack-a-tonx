class AddGoldenFloppyToBlackmarket < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'golden_floppy', min_price: 60_000, current_price: 60_000)
      end
    end
  end
end
