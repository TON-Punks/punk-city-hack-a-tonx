class FreeTournaments::ContributePrizePool
  include Interactor

  delegate :game, to: :context

  POOL_CONTRIBUTION_PERCENTAGE = 0.025

  def call
    context.fail! if tournament.blank?
    context.fail! unless game.praxis_bet_currency?
    context.fail! unless tournament.dynamic_prize_enabled?

    contribute_tournament_prize_pool
  end

  private

  def contribute_tournament_prize_pool
    tournament.increment!(:prize_amount, praxis_comission_contribution)
  end

  def praxis_comission_contribution
    (game.bet * POOL_CONTRIBUTION_PERCENTAGE * 2).floor
  end

  def tournament
    @tournament ||= FreeTournament.running
  end
end
