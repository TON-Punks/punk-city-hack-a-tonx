# == Schema Information
#
# Table name: platformer_statistics
#
#  id         :bigint           not null, primary key
#  top_score  :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_platformer_statistics_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PlatformerStatistic < ApplicationRecord
  belongs_to :user
end
