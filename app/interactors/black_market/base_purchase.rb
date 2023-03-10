class BlackMarket::BasePurchase
  include Interactor
  include RedisHelper
  include TonHelper

  delegate :user, to: :context

  def call
    with_lock "black-market-purchase-#{user.id}" do |locked|
      if locked
        perform
      end
    end
  end

  private

  def create_user_transaction!(total, commission, transaction_type)
    UserTransaction.create!(
      user_session: user.sessions.open.first,
      user: user,
      total: to_nano(total),
      commission: to_nano(commission),
      transaction_type: transaction_type
    )
  end
end
