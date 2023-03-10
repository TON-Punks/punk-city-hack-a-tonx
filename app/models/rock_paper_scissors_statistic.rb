# == Schema Information
#
# Table name: rock_paper_scissors_statistics
#
#  id          :bigint           not null, primary key
#  games_lost  :bigint
#  games_won   :bigint
#  praxis_lost :bigint
#  praxis_won  :bigint
#  ton_lost    :bigint
#  ton_won     :bigint
#  winrate     :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_rock_paper_scissors_statistics_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class RockPaperScissorsStatistic < ApplicationRecord
  include TonHelper

  belongs_to :user

  def pretty_ton_won
    from_nano(ton_won).to_f.round(2)
  end

  def pretty_ton_lost
    from_nano(ton_lost).to_f.round(2)
  end

  def pretty_winrate
    "#{winrate * 100}%"
  end
end
