class RockPaperScissorsGames::Halloween
  extend RedisHelper
  KEY = 'halloween_boss_damage'
  HP_LEVELS = [2500, 5000, 10_000, 25_000, 50_000].freeze

  class << self
    def max_hp
      HP_LEVELS[level - 1]
    end

    def increment_total_damage(damage)
      redis.incrby(KEY, damage)
    end

    def total_damage
      redis.get(KEY).to_i
    end

    def hp_left
      HP_LEVELS.each.with_object(0) do |level_hp, acc|
        acc += level_hp
        break acc - total_damage if acc - total_damage > 0
      end
    end

    def level
      case total_damage
      when 0..2500
        1
      when 2501..5_000
        2
      when 5_001..10_000
        3
      when 10_001..25_000
        4
      when 25_001..50_000
        5
      end
    end
  end
end
