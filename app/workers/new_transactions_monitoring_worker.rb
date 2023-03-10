class NewTransactionsMonitoringWorker
  include Sidekiq::Job
  include RedisHelper

  sidekiq_options queue: 'high', retry: false, lock: :until_executed, on_conflict: :reject

  def perform
    with_lock "transactions-monitoring" do |locked|
      NewTransactionsMonitoringTonhub.call if locked
    end
  end
end
