class RockPaperScissorsGames::SendMovesWorker
  include Sidekiq::Job

  def perform(game_id, redeploy = false)
    game = RockPaperScissorsGame.find(game_id)
    result = RockPaperScissorsGames::ValidateDeploy.call(game: game)

    if result.success?
      RockPaperScissorsGames::SendMoves.call(game: game)
    elsif redeploy
      RockPaperScissorsGames::DeployGame.call(game: game)
      self.class.perform_in(120, game.id, false)
    else
      self.class.perform_in(60, game.id, true)
    end
  end
end
