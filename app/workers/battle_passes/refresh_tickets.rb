class BattlePasses::RefreshTickets
  include Sidekiq::Job
  sidekiq_options queue: 'high', retry: 5

  def perform
    tournament = Tournament.halloween

    BattlePass.includes(:user).find_each do |battle_pass|
      user = battle_pass.user
      tickets_to_create = 5 - user.tournament_tickets.available.for_tournament(tournament).count
      tickets_to_create.times { TournamentTicket.create(user: user, tournament: tournament) }
    end
  end
end
