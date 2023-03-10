FactoryBot.define do
  factory :lootbox do
    address { "" }
    series { :initial }

    trait :with_black_market_purchase do
      after :create do |lootbox|
        lootbox.update(black_market_purchase: create(:black_market_purchase, :with_product))
      end
    end
  end
end
