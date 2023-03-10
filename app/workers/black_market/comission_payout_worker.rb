class BlackMarket::ComissionPayoutWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(user_id, ton_fee)
    BlackMarket::ComissionPayoutProcessor.call(user: User.find(user_id), ton_fee: ton_fee)
  end
end
