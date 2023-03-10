# == Schema Information
#
# Table name: user_halloween_statistics
#
#  id           :bigint           not null, primary key
#  total_damage :bigint           default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_user_halloween_statistics_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserHalloweenStatistic < ApplicationRecord
  belongs_to :user
end
