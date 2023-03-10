# == Schema Information
#
# Table name: crm_notifications
#
#  id         :bigint           not null, primary key
#  crm_type   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  segment_id :bigint
#  user_id    :bigint           not null
#
# Indexes
#
#  index_crm_notifications_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class CrmNotification < ApplicationRecord
  belongs_to :user
end
