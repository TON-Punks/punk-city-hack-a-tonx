class CalculateExperience
  PUNK_MULTIPLIER = 1.1

  BASE_XP = 10
  LOOSE_XP_MULTIPLIER = 0.25
  PRAXIS_GAME_MULTIPLIER = 0.7
  LEVEL_EXPERIENCE_MAPPING = {
    (0...10) => 2,
    (10...20) => 1.9,
    (20...30) => 1.8,
    (30..40) => 1.7,
    (41..50) => 1.6,
    (51...60) => 1.5,
    (60..) => 1.4
  }

  BET_MULTIPLIER_MAPPING = {
    (0...1) => 5200,
    (1...5) => 7400,
    (5...10) => 11_400,
    (10...25) => 8600,
    (25...50) => 6400,
    (50...100) => 5400,
    (100..) => 5400
  }

  class << self
    def call(game:, won:, user:, boss_fight: false)
      if boss_fight
        return game.game_rounds.sum do |round|
                 round.winner == "creator" ? round.winner_damage.to_i : round.loser_damage.to_i
               end
      end

      base_xp = BASE_XP * LEVEL_EXPERIENCE_MAPPING.each { |l, m| break m if l.include?(user.prestige_level) }
      xp = won ? base_xp : (base_xp * LOOSE_XP_MULTIPLIER).ceil

      total = if game.free?
                (xp * UserExperienceMultiplier.call(user)).ceil
              else
                game_bet = relative_game_bet(game)
                bet_multiplier = BET_MULTIPLIER_MAPPING.each { |b, m| break m if b.include?(game_bet.to_f) }
                xp + game_bet / 100 * bet_multiplier
              end

      total *= PUNK_MULTIPLIER if user.punk.present?
      total *= PRAXIS_GAME_MULTIPLIER if game.praxis_bet_currency?

      total
    end

    def relative_game_bet(game)
      if game.ton_bet_currency?
        BigDecimal(game.pretty_bet)
      elsif game.praxis_bet_currency?
        BigDecimal(game.pretty_bet) / 100
      end
    end
  end
end
