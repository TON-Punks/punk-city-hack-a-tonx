class RockPaperScissorsGames::CleanNotificationsWorker
  include Sidekiq::Job

  sidekiq_options queue: 'low'

  def perform
    games = RockPaperScissorsGame
              .joins(:notifications)
              .where(state: %i[creator_won opponent_won archived])
              .where(updated_at: ..30.seconds.ago)

    games.each { |game| RockPaperScissorsGames::RemoveNotificationsWorker.perform_async(game.id) }
  end
end
