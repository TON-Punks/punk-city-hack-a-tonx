# == Schema Information
#
# Table name: referral_rewards
#
#  id                          :bigint           not null, primary key
#  experience                  :integer          default(0), not null
#  praxis                      :integer          default(0), not null
#  ton                         :decimal(16, 10)  default(0.0), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  referral_id                 :bigint           not null
#  rock_paper_scissors_game_id :bigint           not null
#  user_id                     :bigint           not null
#
# Indexes
#
#  index_referral_rewards_on_referral_id                  (referral_id)
#  index_referral_rewards_on_referrals_and_game           (referral_id,rock_paper_scissors_game_id) UNIQUE
#  index_referral_rewards_on_rock_paper_scissors_game_id  (rock_paper_scissors_game_id)
#  index_referral_rewards_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (referral_id => users.id)
#  fk_rails_...  (rock_paper_scissors_game_id => rock_paper_scissors_games.id)
#  fk_rails_...  (user_id => users.id)
#
class ReferralReward < ApplicationRecord
  belongs_to :user
  belongs_to :referral, class_name: "User"
  belongs_to :rock_paper_scissors_game

  scope :purchased, -> { where(operation_type: PURCHASE_OPERATIONS) }
  scope :spent, -> { where(operation_type: SPEND_OPERATIONS) }

  scope :experience_gained, -> { sum(:experience) }
  scope :praxis_gained, -> { sum(:praxis) }
  scope :ton_gained, -> { sum(:ton) }

  scope :for_last_week, -> { where(created_at: 7.days.ago..) }

  class << self
    def for(user, game)
      where(user: user.referred_by, referral: user, rock_paper_scissors_game: game).first_or_create!
    end
  end
end
