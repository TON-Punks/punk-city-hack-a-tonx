class RockPaperScissorsGames::SendNotificationsWorker
  include Sidekiq::Job

  def perform(game_id)
    game = RockPaperScissorsGame.find(game_id)

    RockPaperScissorsGames::SendNotifications.call(game: game)
  end
end
