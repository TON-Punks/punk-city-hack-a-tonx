class FreeTournaments::Create
  PRAXIS_REWARD = 10_000

  include Interactor

  def call
    context.fail! if tournament_running_or_scheduled?

    FreeTournament.create!(
      start_at: Time.now.utc.beginning_of_day + 1.hour,
      finish_at: Time.now.utc.end_of_week,
      state: :started,
      prize_amount: PRAXIS_REWARD,
      prize_currency: :praxis,
      dynamic_prize_enabled: true
    )

    Segments::RecalculationWorker.perform_async(Segments::FreeTournament.name)
  end

  private

  def tournament_running_or_scheduled?
    FreeTournament.running.present? || FreeTournament.scheduled.present?
  end
end
