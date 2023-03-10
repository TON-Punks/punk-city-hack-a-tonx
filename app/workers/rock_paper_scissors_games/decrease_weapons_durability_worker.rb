class RockPaperScissorsGames::DecreaseWeaponsDurabilityWorker
  include Sidekiq::Job

  def perform(game_id)
    game = RockPaperScissorsGame.find(game_id)
    RockPaperScissorsGames::DecreaseWeaponsDurability.call(game: game)
  end
end
