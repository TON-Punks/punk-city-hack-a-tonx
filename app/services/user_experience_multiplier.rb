class UserExperienceMultiplier
  MAX_MULTIPLIER = 1.5
  MIN_MULTIPLIER = 0

  GAMES_COUNT_EXPERIENCE_MAPPING = {
    (0..10) => MAX_MULTIPLIER,
    (11...100) => 1,
    (100...200) => 0.7,
    (200...350) => 0.4,
    (350..) => MIN_MULTIPLIER
  }.freeze

  class << self
    def call(user)
      return MAX_MULTIPLIER if user.last_match_at && user.last_match_at < 4.hours.ago

      games_count = RockPaperScissorsGame
                    .where(creator_id: user.id)
                    .or(RockPaperScissorsGame.where(opponent_id: user.id))
                    .where(RockPaperScissorsGame.arel_table[:created_at].gt(Time.now.utc.beginning_of_day))
                    .count

      calculated_multiplier(games_count)
    end

    private

    def calculated_multiplier(games_count)
      GAMES_COUNT_EXPERIENCE_MAPPING.find { |range, multiplier| break multiplier if range.include?(games_count) }
    end
  end
end
