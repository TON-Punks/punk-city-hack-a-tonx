class FreeTournaments::CalibrationProcessor
  include Interactor

  delegate :user, to: :context

  def call
    return unless matches_calibration_rules?

    assign_segment
    notify_user
  end

  private

  def assign_segment
    user.segments << segment
  end

  def notify_user
    user.with_locale { Telegram::Notifications::FreeTournaments::CalibrationPassed.call(user: user) }
  end

  def matches_calibration_rules?
    ton_games_left.zero? || ton_games_left.negative? ||
      praxis_games_left.zero? || praxis_games_left.negative? ||
      free_games_left.zero? || free_games_left.negative?
  end

  def ton_games_left
    stats[:ton_games_left]
  end

  def praxis_games_left
    stats[:praxis_games_left]
  end

  def free_games_left
    stats[:free_games_left]
  end

  def stats
    @stats ||= FreeTournaments::CalibrationStats.call(user: user).stats
  end

  def segment
    @segment ||= Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT)
  end
end
