# == Schema Information
#
# Table name: referrals
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  referred_id :bigint
#  user_id     :bigint           not null
#
# Indexes
#
#  index_referrals_on_referred_id  (referred_id) UNIQUE
#  index_referrals_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (referred_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class Referral < ApplicationRecord
  belongs_to :user

  belongs_to :referred, class_name: 'User'
end
