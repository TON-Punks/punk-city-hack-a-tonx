# == Schema Information
#
# Table name: segments_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  segment_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_segments_users_on_segment_id              (segment_id)
#  index_segments_users_on_segment_id_and_user_id  (segment_id,user_id) UNIQUE
#  index_segments_users_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (segment_id => segments.id)
#  fk_rails_...  (user_id => users.id)
#
class SegmentsUser < ApplicationRecord
  belongs_to :segment
  belongs_to :user
end
