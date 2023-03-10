class PunkConnections::Disconnect
  include Interactor
  include RedisHelper
  include AfterCommitEverywhere

  delegate :punk_connection, to: :context
  delegate :user, to: :punk_connection
  def call
    with_lock "punk_connection-#{punk_connection.id}" do |locked|
      if locked
        ApplicationRecord.transaction do
          punk_connection.update!(state: :disconnected, connected_at: nil)
          user.update!(experience: 0, prestige_expirience: 0, prestige_level: 0)
          Missions::NeuroboxLevel::ResetHandler.call(user: user)

          after_commit do
            Users::UpdateProfileWorker.perform_in(3, user.id)
          end
        end
      end
    end
  end
end
