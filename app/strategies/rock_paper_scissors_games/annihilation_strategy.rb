class RockPaperScissorsGames::AnnihilationStrategy < RockPaperScissorsGames::BaseStrategy
  def pick_move
    return pick(:annihilation) if first_move?

    if healthier?
      pick_with_ratio(aggressive: 0.45)
    else
      pick_with_ratio(aggressive: 0.65)
    end
  end
end
