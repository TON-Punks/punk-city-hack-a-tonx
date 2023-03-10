# == Schema Information
#
# Table name: zeya_statistics
#
#  id         :bigint           not null, primary key
#  top_score  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_zeya_statistics_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ZeyaStatistic < ApplicationRecord
  belongs_to :user
end
