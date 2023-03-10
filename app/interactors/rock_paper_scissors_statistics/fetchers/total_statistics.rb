class RockPaperScissorsStatistics::Fetchers::TotalStatistics < RockPaperScissorsStatistics::Fetchers::Base
  def call
    context.winrate = winrate
    context.won_games_count = won_games_count
    context.lost_games_count = lost_games_count
  end

  private

  def won_games_count
    @won_games_count = created_games.where(state: :creator_won).count +
                       participated_games.where(state: :opponent_won).count
  end

  def lost_games_count
    @lost_games_count ||= created_games.where(state: :opponent_won).count +
                          participated_games.where(state: :creator_won).count
  end

  def winrate
    return 0 if won_games_count.zero?

    (won_games_count / total.to_f).round(2)
  end

  def total
    @total ||= won_games_count + lost_games_count
  end
end
