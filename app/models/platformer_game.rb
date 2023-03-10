# == Schema Information
#
# Table name: platformer_games
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
#  index_platformer_games_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PlatformerGame < ApplicationRecord
  belongs_to :user

  scope :by_score, -> { order(score: :desc) }

  EXPERIENCE_DIVIDER = 200.0

  def increase_experience!
    user.add_experience!(user_experience)
  end

  def user_experience
    (score / EXPERIENCE_DIVIDER).ceil
  end
end
