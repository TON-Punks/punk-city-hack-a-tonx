class RockPaperScissorsGames::Matchmaking::SearchMessageStorage
  include RedisHelper

  TTL = 12.hours.to_i

  def set(game_id, message_id)
    redis.setnx(redis_key_for_game(game_id), message_id)
    redis.expire(redis_key_for_game(game_id), TTL)
  end

  def telegram_request_for(game_id)
    message_id = fetched_message_id(game_id)
    return if message_id.blank?

    OpenStruct.new(callback_query: OpenStruct.new(message: OpenStruct.new(message_id: message_id.to_i)))
  end

  private

  def fetched_message_id(game_id)
    redis.get(redis_key_for_game(game_id))
  end

  def redis_key_for_game(id)
    "matchmaking-game-#{id}-message-id"
  end
end
