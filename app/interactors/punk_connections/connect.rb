class PunkConnections::Connect
  include Interactor
  include RedisHelper
  include AfterCommitEverywhere

  delegate :punk_connection, to: :context
  delegate :user, :punk, to: :punk_connection

  def call
    with_lock "punk_connection-#{punk_connection.id}" do |locked|
      if locked
        return if punk.user == punk_connection.user

        ApplicationRecord.transaction do
          PunkConnections::Disconnect.call(punk_connection: punk.connected_punk_connection) if punk.user

          punk_connection.update!(state: :connected, connected_at: Time.zone.now)

          if user.experience > punk.experience
            punk.update!(experience: user.experience)
          end

          if user.prestige_level > punk.prestige_level || (user.prestige_level == punk.prestige_level && user.prestige_expirience > punk.prestige_expirience)
            punk.update!(prestige_expirience: user.prestige_expirience, prestige_level: user.prestige_level)
          end

          Missions::NeuroboxLevel::ResetHandler.call(user: user)

          after_commit do
            Users::UpdateProfileWorker.perform_in(3, user.id)
          end
        end
      end
    end
  end
end
