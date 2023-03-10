class Praxis::TonExchange < Praxis::BaseExchange
  def perform
    ApplicationRecord.transaction do
      user.praxis_transactions.create!(operation_type: PraxisTransaction::TON_EXCHANGE, quantity: rate.praxis)

      payment_result = BlackMarket::TonPaymentProcessor.call(ton_price: rate.ton, user: user)
      context.fail!(error_message: payment_result.error_message) unless payment_result.success?

      context.praxis_received = rate.praxis
    end
  end

  private

  def rate
    @rate ||= Praxis::TonExchange::RateFetcher::RATES.fetch(context.rate.to_sym)
  end
end
