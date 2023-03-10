class Users::UpdateStatistics
  include Sidekiq::Worker

  def perform
    User.where(last_match_at: 12.minutes.ago..).each do |user|
      Users::UpdateProfileWorker.perform_async(user.id)
    end

    User.where(id: PlatformerGame.where(created_at: 12.minutes.ago..).pluck('user_id')).each do |user|
      user.recalculate_platformer_statistic!
    end

    User.where(id: ZeyaGame.where(updated_at: 12.minutes.ago..).pluck('user_id')).each do |user|
      user.recalculate_zeya_statistic!
    end
  end
end
