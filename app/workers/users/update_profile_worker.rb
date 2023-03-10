class Users::UpdateProfileWorker
  include Sidekiq::Worker

  sidekiq_options queue: "low"

  def perform(user_id)
    user = User.find(user_id)
    user.recalculate_rock_paper_scissors_statistic!
    Users::GenerateProfileImage.call(user: user)
    user.touch
  end
end
