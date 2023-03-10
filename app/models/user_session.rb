# == Schema Information
#
# Table name: user_sessions
#
#  id         :bigint           not null, primary key
#  closed_at  :datetime
#  state      :integer          default("open"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserSession < ApplicationRecord
  include AASM

  belongs_to :user

  enum state: { open: 0, closed: 1 }

  aasm column: :state, enum: true do
    state :open, initial: true
    state :closed

    event :close, before: :set_closed_at do
      transitions from: :open, to: :closed
    end
  end

  private

  def set_closed_at
    self.closed_at = updated_at
  end
end
