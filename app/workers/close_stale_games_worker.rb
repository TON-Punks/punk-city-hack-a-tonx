class CloseStaleGamesWorker
  include Sidekiq::Job

  sidekiq_options queue: 'low'

  def perform
    RockPaperScissorsGames::FinishStaleGames.call
  end
end
