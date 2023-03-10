class Praxis::FastExchange < Praxis::BaseExchange
  def perform
    ApplicationRecord.transaction do
      user.remove_experience!(rate.exp)
      user.praxis_transactions.create!(operation_type: PraxisTransaction::FAST_EXCHANGE, quantity: rate.praxis)

      context.fail!(error_message: I18n.t("bank.fast_exchange.errors.insufficient_experience")) unless user.experience_balance_valid?
      context.fail!(error_message: I18n.t("common.error")) unless user.praxis_balance_valid?

      multiplier_manager.increase
    end
  end

  private

  def rate
    @rate ||= Praxis::FastExchange::RateCalculator.call(user.id)
  end

  def multiplier_manager
    @multiplier_manager ||= Praxis::FastExchange::MultiplierManager.new(user.id)
  end
end
