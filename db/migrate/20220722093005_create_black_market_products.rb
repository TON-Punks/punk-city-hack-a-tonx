class CreateBlackMarketProducts < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    create_table :black_market_products do |t|
      t.string :slug, null: false, index: { unique: true }
      t.bigint :min_price, null: false, default: 0
      t.bigint :current_price, null: false, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        BlackMarketProductStub.create!(slug: 'wl_mutant_toadz', min_price: 500, current_price: 1000)
        BlackMarketProductStub.create!(slug: 'animated_punk', min_price: 4000, current_price: 8000)
      end
    end
  end
end
