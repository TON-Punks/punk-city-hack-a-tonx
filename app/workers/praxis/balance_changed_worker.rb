class Praxis::BalanceChangedWorker
  include Sidekiq::Worker

  sidekiq_options queue: "low", retry: 5

  def perform(praxis_transaction_id)
    praxis_transaction = PraxisTransaction.find(praxis_transaction_id)
    return if PraxisTransaction::OPERATIONS_TO_NOTIFY.exclude?(praxis_transaction.operation_type.to_sym)

    praxis_transaction.user.with_locale do
      Telegram::Notifications::NewPraxisBalance.call(user: praxis_transaction.user)
    end
  end
end
