FactoryBot.define do
  factory :punk_connection do
    user
    punk
    state { 0 }

    trait :connected do
      state { :connected }
    end
  end
end
