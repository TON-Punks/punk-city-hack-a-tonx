class Punks::ValidateConnectionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(punk_id)
    punk = Punk.find(punk_id)
    Punks::ValidateConnection.call(punk: punk)
  end
end
