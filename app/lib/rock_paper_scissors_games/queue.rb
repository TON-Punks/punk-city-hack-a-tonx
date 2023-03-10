class RockPaperScissorsGames::Queue
  extend RedisHelper

  KEY = 'rock_paper_scissors_waiting_room'

  def self.pop
    redis.rpop(KEY)
  end

  def self.push(id)
    redis.lpush(KEY, id)
  end

  def self.remove(id)
    redis.lrem(KEY, 0, id)
  end

  def self.clear
    redis.del(KEY)
  end
end
