# == Schema Information
#
# Table name: missions
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  state      :integer          not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_missions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Mission < ApplicationRecord
  belongs_to :user

  enum state: { running: 0, completed: 1, failed: 2 }

  def can_be_finished?
    raise NotImplementedError
  end
end
