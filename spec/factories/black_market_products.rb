FactoryBot.define do
  factory :black_market_product do
    slug { "product" }
    min_price { 100 }
    current_price { 1000 }
  end
end
