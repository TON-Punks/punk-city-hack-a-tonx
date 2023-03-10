class RockPaperScissorsGames::RandomStrategy < RockPaperScissorsGames::BaseStrategy
  def pick_move
    pick_considering_perks(rand(1..5))
  end
end
