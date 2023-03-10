# == Schema Information
#
# Table name: zeya_games
#
#  id          :bigint           not null, primary key
#  finished_at :datetime
#  score       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_zeya_games_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ZeyaGame < ApplicationRecord
  belongs_to :user

  scope :by_score, -> { order(score: :desc) }

  EXPERIENCE_THRESHOLDS = [5000, 50_000, 1_500_000, BigDecimal::INFINITY]
  EXPERIENCE_DIVIDERS = [500, 2000, 50_000, 100_000]

  after_destroy do
    user.recalculate_zeya_statistic!
  end

  def increase_experience!
    user.add_experience!(user_experience)
  end

  def user_experience
    calculated = 0
    total_score = 0
    4.times do |i|
      total_score += (([score, EXPERIENCE_THRESHOLDS[i]].min - calculated) / EXPERIENCE_DIVIDERS[i]).ceil
      calculated += EXPERIENCE_THRESHOLDS[i]
      break if score < EXPERIENCE_THRESHOLDS[i]
    end

    total_score
  end
end
