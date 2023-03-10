class Users::UpdateWeaponsImageWorker
  include Sidekiq::Worker

  sidekiq_options queue: "low"

  def perform(user_id)
    user = User.find(user_id)
    Users::GenerateWeaponsImage.call(user: user)
  end
end
