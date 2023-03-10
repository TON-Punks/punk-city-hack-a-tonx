class Praxis::PremiumExchange < Praxis::BaseExchange
  include TonHelper

  def perform
    ApplicationRecord.transaction do
      user.remove_experience!(rate.exp)
      user.praxis_transactions.create!(operation_type: PraxisTransaction::PREMIUM_EXCHANGE, quantity: rate.praxis)

      context.fail!(error_message: I18n.t("bank.fast_exchange.errors.insufficient_experience")) unless user.experience_balance_valid?
      context.fail!(error_message: I18n.t("common.error")) unless user.praxis_balance_valid?

      payment_result = BlackMarket::TonPaymentProcessor.call(ton_price: rate.ton_fee, user: user)
      context.fail!(error_message: payment_result.error_message) unless payment_result.success?

      context.praxis_received = rate.praxis
      create_user_transaction!
    end
  end

  private

  def rate
    @rate ||= Praxis::PremiumExchange::RateFetcher::RATES.fetch(context.rate.to_sym)
  end

  def create_user_transaction!
    UserTransaction.create!(
      user_session: user.sessions.open.first,
      user: user,
      total: to_nano(rate.ton_fee),
      commission: to_nano(rate.ton_fee),
      transaction_type: 'premium_exchange'
    )
  end
end
