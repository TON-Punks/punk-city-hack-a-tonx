class Users::CheckPunkConnectionWorker
  include Sidekiq::Worker

  sidekiq_options queue: "low"

  def perform(user_id)
    user = User.find(user_id)
    Users::CheckPunkConnection.call(user: user)
  end
end
