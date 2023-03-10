class RockPaperScissorsGames::BaseStrategy
  SAFE_PICKS = %i[katana hack pistol]
  AGGRESSIVE_PICKS = %i[grenade annihilation]

  def initialize(game:, rounds_count:, total_damage:)
    @game = game
    @rounds_count = rounds_count
    @total_damage = total_damage
  end

  def pick_move
    raise NotImplementedError, "Strategy must implement #pick_move"
  end

  private

  attr_reader :rounds_count, :total_damage, :game

  def pick(name)
    pick_considering_perks(RockPaperScissorsGame::NAME_TO_MOVE[name])
  end

  def first_move?
    rounds_count.zero?
  end

  def healthier?
    total_damage['opponent'] < total_damage['creator']
  end

  def pick_with_ratio(aggressive:)
    if SecureRandom.rand < aggressive
      pick(AGGRESSIVE_PICKS.sample)
    else
      pick(SAFE_PICKS.sample)
    end
  end

  def pick_considering_perks(move)
    available_moves.include?(move) ? move : available_moves.sample
  end

  def available_moves
    @available_moves ||= begin
      user = game.creator.bot? ? game.creator : game.opponent
      game.available_moves(user)
    end
  end
end
