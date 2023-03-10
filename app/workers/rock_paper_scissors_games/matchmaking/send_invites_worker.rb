class RockPaperScissorsGames::Matchmaking::SendInvitesWorker
  include Sidekiq::Job

  def perform
    RockPaperScissorsGames::Matchmaking::SendInvites.call
  end
end
