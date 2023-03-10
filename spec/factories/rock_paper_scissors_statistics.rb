FactoryBot.define do
  factory :rock_paper_scissors_statistic do
    user
    winrate { 0 }
    ton_won { 0 }
    ton_lost { 0 }
    games_won { 0 }
    games_lost { 0 }
  end
end
