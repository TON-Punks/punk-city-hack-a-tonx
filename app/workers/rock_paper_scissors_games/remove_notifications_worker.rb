class RockPaperScissorsGames::RemoveNotificationsWorker
  include Sidekiq::Job

  def perform(game_id)
    game = RockPaperScissorsGame.find(game_id)

    RockPaperScissorsGames::RemoveNotifications.call(game: game)
  end
end
