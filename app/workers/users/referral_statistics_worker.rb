class Users::ReferralStatisticsWorker
  include Sidekiq::Worker

  sidekiq_options queue: "low"

  def perform
    User.find_each do |user|
      next if user.referral_rewards.for_last_week.blank?

      Telegram::Notifications::WeeklyReferralRewards.call(user: user)
    end
  end
end
