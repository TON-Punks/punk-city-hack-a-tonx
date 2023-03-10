class AddExtraTicketsPurchase < ActiveRecord::Migration[6.1]
  class BlackMarketProductStub < ApplicationRecord
    self.table_name = :black_market_products
  end

  def change
    BlackMarketProductStub.create!(slug: 'halloween_tickets', min_price: 2499, current_price: 2499)
  end
end
