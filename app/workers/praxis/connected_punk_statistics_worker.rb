class Praxis::ConnectedPunkStatisticsWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low', retry: false

  def perform
    Telegram::Notifications::ConnectedPunkStatistics.call(
      punks_count: connected_punks_ids.count,
      additional_punks_count: additional_punks_count,
      praxis_reward: weekly_praxis_rewards_amount
    )
  end

  private

  def connected_punks_owners
    PunkConnection.connected.joins(:punk).pluck(:owner).uniq
  end

  def connected_punks_ids
    PunkConnection.connected.joins(:punk).pluck(:punk_id)
  end

  def additional_punks_count
    Punk.where(owner: connected_punks_owners).count - connected_punks_ids.count
  end

  def weekly_praxis_rewards_amount
    PraxisTransaction.where(operation_type: PraxisTransaction::CONNECTED_PUNK_BONUS, created_at: 7.days.ago..).sum(:quantity)
  end
end
