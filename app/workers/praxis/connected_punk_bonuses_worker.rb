class Praxis::ConnectedPunkBonusesWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low', retry: 5

  def perform
    rewarded_punks_ids = []
    User.joins(:punk_connections).where(punk_connections: { state: :connected }).find_each do |user|
      result = Praxis::Bonus::ConnectedPunk.call(user: user, rewarded_punks_ids: rewarded_punks_ids)
      rewarded_punks_ids += result.new_rewarded_punks_ids if result.new_rewarded_punks_ids.present?
    end
  end
end
