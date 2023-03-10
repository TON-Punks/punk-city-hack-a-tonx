class FreeTournaments::ContributionWorker
  include Sidekiq::Job

  sidekiq_options queue: "low"

  def perform(user_id, game_id)
    FreeTournaments::Contribute.call(user: User.find(user_id), game: RockPaperScissorsGame.find(game_id))
  end
end
