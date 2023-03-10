# == Schema Information
#
# Table name: battle_passes
#
#  id         :bigint           not null, primary key
#  kind       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_battle_passes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class BattlePass < ApplicationRecord
  belongs_to :user

  scope :halloween, -> { where(kind: :halloween) }
end
