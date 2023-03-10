class RockPaperScissorsGames::PistolStrategy < RockPaperScissorsGames::BaseStrategy
  def pick_move
    return pick(:pistol) if first_move?

    if healthier?
      pick_with_ratio(aggressive: 0.8)
    else
      pick_with_ratio(aggressive: 0.5)
    end
  end
end
