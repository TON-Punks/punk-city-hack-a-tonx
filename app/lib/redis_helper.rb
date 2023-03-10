module RedisHelper
  LOCK_TTL = 3000
  RETRY_COUNT = 6
  RETRY_DELAY = 600

  def with_lock(key)
    redlock_client.lock(key, LOCK_TTL, retry_count: RETRY_COUNT) do |locked|
      yield(locked)
    end
  end

  def with_lock!(key)
    redlock_client.lock!(key, LOCK_TTL, retry_count: RETRY_COUNT) do |locked|
      yield(locked)
    end
  end

  def redis
    @redis ||= Redis.new(url: ENV["REDIS_URL"], password: ENV["REDIS_PASSWORD"], port: ENV["REDIS_PORT"])
  end

  private

  def redlock_client
    @redlock_client ||= Redlock::Client.new([redis])
  end
end
