class RockPaperScissorsGames::KatanaStrategy < RockPaperScissorsGames::BaseStrategy
  def pick_move
    return pick(:katana) if first_move?

    if healthier?
      pick_with_ratio(aggressive: 0.6)
    else
      pick_with_ratio(aggressive: 0.2)
    end
  end
end
