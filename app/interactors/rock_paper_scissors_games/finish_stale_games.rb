class RockPaperScissorsGames::FinishStaleGames
  include Interactor

  def call
    RockPaperScissorsGame.where(bet_currency: %i[praxis ton])
                         .started.with_latest_round_before(5.minutes.ago).each(&:force_close!)
    RockPaperScissorsGame.where(bet_currency: %i[praxis ton])
                         .started.without_rounds.where(updated_at: ..5.minutes.ago).each(&:archive!)

    RockPaperScissorsGame.free.started.with_latest_round_before(90.seconds.ago).each(&:force_close!)
    RockPaperScissorsGame.free.started.without_rounds.where(updated_at: ..90.seconds.ago).each(&:archive!)

    RockPaperScissorsGame.free.created.without_rounds.where(updated_at: ..1.hour.ago).each(&:archive!)
  end
end
