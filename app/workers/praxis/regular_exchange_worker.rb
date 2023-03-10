class Praxis::RegularExchangeWorker
  EXPERIENCE_AMOUNT = 1000
  PRAXIS_AMOUNT = 100

  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id)
    user = User.find(user_id)

    ApplicationRecord.transaction do
      user.remove_experience!(EXPERIENCE_AMOUNT)
      user.praxis_transactions.create!(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: PRAXIS_AMOUNT)

      raise ActiveRecord::Rollback unless user.experience_balance_valid?
      raise ActiveRecord::Rollback unless user.praxis_balance_valid?

      user.with_locale { Telegram::Notifications::RegularExchangeCompleted.call(user: user, praxis: PRAXIS_AMOUNT) }
    end
  end
end
