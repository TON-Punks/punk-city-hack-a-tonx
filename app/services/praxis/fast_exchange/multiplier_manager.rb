class Praxis::FastExchange::MultiplierManager
  include RedisHelper

  DEFAULT_MIN_MULTIPLIER = 20
  MAX_MULTIPLIER = 100

  TTL = 24.hours

  def initialize(user_id)
    @user_id = user_id
  end

  def exchange_rate
    (MAX_MULTIPLIER - current_multiplier).to_f / 1000
  end

  def increase
    return if current_multiplier >= MAX_MULTIPLIER

    redis.set(redis_multiplier_key, DEFAULT_MIN_MULTIPLIER) unless redis.exists?(redis_multiplier_key)
    redis.incr(redis_multiplier_key)
    redis.expire(redis_multiplier_key, TTL)

    schedule_multiplier_decrease
  end

  def decrease
    return if current_multiplier <= DEFAULT_MIN_MULTIPLIER

    redis.decr(redis_multiplier_key)
  end

  def current_multiplier
    (redis.get(redis_multiplier_key).presence || DEFAULT_MIN_MULTIPLIER).to_i
  end

  private

  attr_reader :user_id

  def schedule_multiplier_decrease
    next_time_schedule = (next_time.presence || Time.now.utc.change(usec: 0)).utc + 600.seconds
    Praxis::FastExchangeDecreaseWorker.perform_in(next_time_schedule, user_id)
    redis.set(redis_next_decrease_time_key, next_time_schedule.to_i)
  end

  def next_time
    @next_time ||= begin
      redis_next_time = redis.get(redis_next_decrease_time_key)
      return if redis_next_time.blank?

      parsed_time = Time.at(redis_next_time.to_i)
      parsed_time.future? ? parsed_time : nil
    end
  end

  def redis_next_decrease_time_key
    @redis_next_decrease_time_key ||= "regular-exchange-decrease-time-user-#{user_id}"
  end

  def redis_multiplier_key
    @redis_multiplier_key ||= "regular-exchange-multiplier-user-#{user_id}"
  end
end
