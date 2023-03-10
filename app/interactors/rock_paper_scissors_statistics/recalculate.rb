class RockPaperScissorsStatistics::Recalculate
  include Interactor

  delegate :statistic, to: :context
  delegate :user, to: :statistic

  def call
    statistic.update(total_statistics.merge(ton_statistics).merge(praxis_statistics))
  end

  private

  def total_statistics
    {
      winrate: fetched_total_statistics.winrate,
      games_won: fetched_total_statistics.won_games_count,
      games_lost: fetched_total_statistics.lost_games_count
    }
  end

  def ton_statistics
    {
      ton_won: fetched_ton_statistics.won_amount,
      ton_lost: fetched_ton_statistics.lost_amount
    }
  end

  def praxis_statistics
    {
      praxis_won: fetched_praxis_statistics.won_amount,
      praxis_lost: fetched_praxis_statistics.lost_amount
    }
  end

  def fetched_total_statistics
    @fetched_total_statistics ||= RockPaperScissorsStatistics::Fetchers::TotalStatistics.call(user: user)
  end

  def fetched_ton_statistics
    @fetched_ton_statistics ||= RockPaperScissorsStatistics::Fetchers::TonStatistics.call(user: user)
  end

  def fetched_praxis_statistics
    @fetched_praxis_statistics ||= RockPaperScissorsStatistics::Fetchers::PraxisStatistics.call(user: user)
  end
end
