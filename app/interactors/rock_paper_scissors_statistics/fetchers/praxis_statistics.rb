class RockPaperScissorsStatistics::Fetchers::PraxisStatistics < RockPaperScissorsStatistics::Fetchers::Base
  def call
    context.won_amount = transactions_sum(PraxisTransaction::GAME_WON)
    context.lost_amount = transactions_sum(PraxisTransaction::GAME_LOST)
  end

  private

  def transactions_sum(operation_type)
    user.praxis_transactions.where(operation_type: operation_type).sum(:quantity)
  end
end
