class RockPaperScissorsGames::ValidateCompletenessWorker
  include Sidekiq::Job

  def perform(game_id)
    game = RockPaperScissorsGame.find(game_id)
    result = RockPaperScissorsGames::ValidateCompleteness.call(game: game)
  end
end
