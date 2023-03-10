class RockPaperScissorsGames::JoinByBotWorker
  include Sidekiq::Job
  sidekiq_options queue: 'high', retry: 2

  def perform(game_id)
    RockPaperScissorsGames::JoinByBot.call(game_id: game_id)
  end
end
