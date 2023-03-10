class Users::GameLeavePenalty
  extend RedisHelper

  COMPLETED_GAMES_THRESHOLD = 5
  MAX_TIMEOUT = 1800
  TIMEOUTS = [60, 180, 300, 900, 1800]

  attr_reader :user, :keys
  delegate :redis, to: :class

  def initialize(user)
    @user = user
    @keys = {
      timeout: "game-leave-penalty-#{user.id}",
      left_games: "game-left-count-#{user.id}",
      completed_games: "game-completed-#{user.id}"
    }
  end

  def create
    left_games = redis.get(keys[:left_games]).to_i
    timeout = TIMEOUTS[left_games] || MAX_TIMEOUT
    redis.incr(keys[:left_games])
    redis.del(keys[:completed_games])
    redis.setex(keys[:timeout], timeout, true)
  end

  def exists?
    redis.get(keys[:timeout])
  end

  def ttl
    redis.ttl(keys[:timeout])
  end

  def increment_completed_games
    return if !redis.get(keys[:left_games])

    completed_games = redis.incr(keys[:completed_games])
    destroy if completed_games == COMPLETED_GAMES_THRESHOLD
  end

  def destroy
    redis.del(keys[:timeout])
    redis.del(keys[:left_games])
    redis.del(keys[:completed_games])
  end
end
