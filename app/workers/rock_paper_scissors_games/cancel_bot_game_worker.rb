class RockPaperScissorsGames::CancelBotGameWorker
  include Sidekiq::Job

  def perform(game_id)
    game = RockPaperScissorsGame.find(game_id)
    game.destroy! if game.created?
  end
end
