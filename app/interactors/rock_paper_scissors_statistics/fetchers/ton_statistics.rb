class RockPaperScissorsStatistics::Fetchers::TonStatistics < RockPaperScissorsStatistics::Fetchers::Base
  PAYOUT_RATION = 0.9
  BETS_PER_GAME = 2

  def call
    context.won_amount = won_games.sum { |game| game.bet * BETS_PER_GAME * PAYOUT_RATION }
    context.lost_amount = lost_games.sum(&:bet)
  end

  private

  def won_games
    @won_games = created_games.where(state: :creator_won) + participated_games.where(state: :opponent_won)
  end

  def lost_games
    @lost_games ||= created_games.where(state: :opponent_won) + participated_games.where(state: :creator_won)
  end

  def created_games
    super.with_ton_bet
  end

  def participated_games
    super.with_ton_bet
  end
end
