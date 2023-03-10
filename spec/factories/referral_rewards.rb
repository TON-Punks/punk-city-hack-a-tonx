FactoryBot.define do
  factory :referral_reward do
    user
    rock_paper_scissors_game
    experience { 1 }
    praxis { 1 }
    ton { 9.9 }
  end
end
