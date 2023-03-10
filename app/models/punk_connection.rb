# == Schema Information
#
# Table name: punk_connections
#
#  id           :bigint           not null, primary key
#  connected_at :datetime
#  state        :integer          default("requested"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  punk_id      :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_punk_connections_on_punk_id  (punk_id)
#  index_punk_connections_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (punk_id => punks.id)
#  fk_rails_...  (user_id => users.id)
#
class PunkConnection < ApplicationRecord
  enum state: { requested: 0, connected: 1, disconnected: 2 }

  belongs_to :user, touch: true
  belongs_to :punk
end
