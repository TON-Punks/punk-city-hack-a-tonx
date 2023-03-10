class RockPaperScissorsGames::UpdateNotificationsWorker
  include Sidekiq::Job

  sidekiq_options queue: 'high'

  def perform(game_id)
    game = RockPaperScissorsGame.find(game_id)

    RockPaperScissorsGames::UpdateNotifications.call(game: game)
  end
end
