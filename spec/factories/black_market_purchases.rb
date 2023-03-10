FactoryBot.define do
  factory :black_market_purchase do
    user
    praxis_transaction
    data { {} }

    trait :with_product do
      black_market_product
    end
  end
end
