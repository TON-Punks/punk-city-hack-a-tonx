# == Schema Information
#
# Table name: user_free_tournament_statistics
#
#  id                 :bigint           not null, primary key
#  games_lost         :integer          default(0), not null
#  games_won          :integer          default(0), not null
#  position           :integer
#  reward             :integer
#  score              :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  free_tournament_id :bigint           not null
#  user_id            :bigint           not null
#
# Indexes
#
#  index_on_free_tournament_statistics                          (free_tournament_id,user_id) UNIQUE
#  index_user_free_tournament_statistics_on_free_tournament_id  (free_tournament_id)
#  index_user_free_tournament_statistics_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (free_tournament_id => free_tournaments.id)
#  fk_rails_...  (user_id => users.id)
#
class UserFreeTournamentStatistic < ApplicationRecord
  belongs_to :free_tournament
  belongs_to :user

  scope :by_position, -> { order(position: :asc) }

  def games_count
    games_won + games_lost
  end
end
