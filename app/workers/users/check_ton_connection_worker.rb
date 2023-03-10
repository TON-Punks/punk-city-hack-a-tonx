class Users::CheckTonConnectionWorker
  include Sidekiq::Worker

  MAX_RETRIES = 10

  sidekiq_options queue: "low"

  def perform(user_id, retries = 0)
    return if retries > MAX_RETRIES

    user = User.find(user_id)
    Users::CheckTonConnection.call(user: user, retries: retries)
  end
end
