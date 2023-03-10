FactoryBot.define do
  factory :game_round do
    rock_paper_scissors_game
    winner { }
    creator { 1 }
    opponent { 1 }
  end
end
