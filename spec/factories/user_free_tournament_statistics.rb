FactoryBot.define do
  factory :user_free_tournament_statistic do
    free_tournament
    user
    games_count { 1 }
  end
end
