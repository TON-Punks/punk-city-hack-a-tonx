class RockPaperScissorsGames::FreeGamesCounter
  extend RedisHelper

  LIMIT = 50_000
  TTL = 24.hours

  def self.hit_limit?
    redis.get(key).to_i >= LIMIT
  end

  def self.increment
    current_counter = redis.incr(self.key)
    redis.expire(key, TTL)
  end

  def self.key
    "rock_paper_scissors_free_games_#{Date.today.to_s}"
  end
end
