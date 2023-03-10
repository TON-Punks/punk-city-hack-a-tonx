class RockPaperScissorsGames::GrenadeStrategy < RockPaperScissorsGames::BaseStrategy
  def pick_move
    return pick(:grenade) if first_move?

    if healthier?
      pick_with_ratio(aggressive: 0.2)
    else
      pick_with_ratio(aggressive: 0.7)
    end
  end
end
