class RockPaperScissorsGames::RepeatStrategy < RockPaperScissorsGames::BaseStrategy
  include RedisHelper

  DEFAULT_EXPIRATION = 36.hours
  ALL_MOVES_SELECTION_PROBABILITY = 0.2

  def pick_move
    if odd_move.present?
      add_bot_move(odd_move)
      pick_considering_perks(odd_move)
    else
      pick_considering_perks(random_move).tap do |move|
        add_bot_move(move)
      end
    end
  end

  private

  def odd_move
    @odd_move ||= begin
      detected_move = previous_bot_moves.tally.detect { |move_name, moves_count| moves_count.odd? }
      detected_move.present? ? detected_move.first : nil
    end
  end

  def all_moves
    @all_moves ||= RockPaperScissorsGame::NAME_TO_MOVE.values
  end

  def strategy_moves
    @strategy_moves ||= all_moves - previous_bot_moves.uniq
  end

  def add_bot_move(move)
    redis.pipelined do |pipeline|
      pipeline.rpush(redis_storage_key, move)
      pipeline.expire(redis_storage_key, DEFAULT_EXPIRATION)
    end
  end

  def previous_bot_moves
    @previous_bot_moves ||= redis.lrange(redis_storage_key, 0, -1).map(&:to_i)
  end

  def redis_storage_key
    "bot-moves-game-#{game.id}"
  end

  def random_move
    if SecureRandom.rand < ALL_MOVES_SELECTION_PROBABILITY
      all_moves.sample
    else
      (strategy_moves.presence || all_moves).sample
    end
  end
end
