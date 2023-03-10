class Praxis::FastExchangeDecreaseWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id)
    Praxis::FastExchange::MultiplierManager.new(user_id).decrease
  end
end
