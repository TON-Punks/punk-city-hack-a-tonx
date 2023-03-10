class Tournaments::UpdateBalanceWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(tournament_id)
    tournament = Tournament.find(tournament_id)
    Tournaments::UpdateBalance.call(tournament: tournament)
  end
end
