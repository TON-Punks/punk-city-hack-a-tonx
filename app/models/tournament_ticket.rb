# == Schema Information
#
# Table name: tournament_tickets
#
#  id                          :bigint           not null, primary key
#  state                       :integer          default("available"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  platformer_game_id          :bigint
#  rock_paper_scissors_game_id :bigint
#  tournament_id               :bigint
#  user_id                     :bigint           not null
#
# Indexes
#
#  index_tournament_tickets_on_platformer_game_id           (platformer_game_id)
#  index_tournament_tickets_on_rock_paper_scissors_game_id  (rock_paper_scissors_game_id)
#  index_tournament_tickets_on_tournament_id                (tournament_id)
#  index_tournament_tickets_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (platformer_game_id => platformer_games.id)
#  fk_rails_...  (rock_paper_scissors_game_id => rock_paper_scissors_games.id)
#  fk_rails_...  (tournament_id => tournaments.id)
#  fk_rails_...  (user_id => users.id)
#
class TournamentTicket < ApplicationRecord
  belongs_to :user
  belongs_to :tournament, optional: true
  belongs_to :platformer_game, optional: true
  belongs_to :rock_paper_scissors_game, optional: true

  enum state: { available: 0, used: 1 }

  scope :for_tournament, -> tournament { where(tournament: tournament) }
end
