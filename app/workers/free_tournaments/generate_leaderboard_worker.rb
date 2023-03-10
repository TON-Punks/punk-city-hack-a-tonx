class FreeTournaments::GenerateLeaderboardWorker
  include Sidekiq::Job

  sidekiq_options queue: "low"

  def perform
    FreeTournaments::RecalculateStatistics.call
    FreeTournaments::Leaderboard::Generate.call
  end
end
