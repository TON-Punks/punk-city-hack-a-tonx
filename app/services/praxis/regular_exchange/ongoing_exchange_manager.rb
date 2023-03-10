class Praxis::RegularExchange::OngoingExchangeManager
  include RedisHelper

  def initialize(user_id)
    @user_id = user_id
  end

  def time_left
    ttl = redis.ttl(redis_key)

    ttl.positive? ? ttl : nil
  end

  def set_time_left(interval)
    redis.setex(redis_key, interval, "1")
  end

  private

  attr_reader :user_id

  def redis_key
    "regular-exchange-user-blocked-#{user_id}"
  end
end
