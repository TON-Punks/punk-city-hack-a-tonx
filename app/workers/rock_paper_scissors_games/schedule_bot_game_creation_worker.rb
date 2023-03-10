class RockPaperScissorsGames::ScheduleBotGameCreationWorker
  include Sidekiq::Job
  sidekiq_options queue: 'high', retry: 5

  def perform
    RockPaperScissorsGames::ScheduleBotGameCreation.call
  end
end
