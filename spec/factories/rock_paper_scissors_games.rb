FactoryBot.define do
  factory :rock_paper_scissors_game do
    creator { create(:user) }
    opponent { nil }
    bot { false }
    state { 0 }

    trait :with_opponent do
      opponent { create(:user) }
    end

    trait :started do
      state { :started }
    end

    trait :paid do
      bet_currency { :ton }
    end
  end
end
