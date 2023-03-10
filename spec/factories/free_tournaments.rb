FactoryBot.define do
  factory :free_tournament do
    state { :started }
    start_at { "2022-12-29 23:34:24" }
    finish_at { "2022-12-29 23:34:24" }
    prize_amount { 1000 }
    prize_currency { :praxis }
  end
end
