# == Schema Information
#
# Table name: tournaments
#
#  id          :bigint           not null, primary key
#  address     :string
#  balance     :bigint           default(0), not null
#  expires_at  :datetime
#  finishes_at :datetime
#  kind        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Tournament < ApplicationRecord
  include TonHelper

  def self.current
    find_by(expires_at: Date.current.end_of_day)
  end

  def self.halloween
    find_by(kind: :halloween)
  end

  def pretty_balance
    from_nano(balance)
  end
end
