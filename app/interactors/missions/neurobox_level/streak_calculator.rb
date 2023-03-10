class Missions::NeuroboxLevel::StreakCalculator
  include Interactor

  delegate :user, to: :context

  MIN_LEVEL_STREAK = 1
  MAX_LEVEL_STREAK = 4

  LEVELS_MULTIPLIER = 40
  MAX_LEVEL_FOR_CALCULATOR = 120

  def call
    context.level = [calculated_level, MIN_LEVEL_STREAK].max
  end

  def calculated_level
    return MIN_LEVEL_STREAK if level >= MAX_LEVEL_FOR_CALCULATOR

    MAX_LEVEL_STREAK - (level.to_f / LEVELS_MULTIPLIER).floor
  end

  def level
    @level ||= user.effective_prestige_level
  end
end
