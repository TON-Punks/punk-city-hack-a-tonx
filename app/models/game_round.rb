# == Schema Information
#
# Table name: game_rounds
#
#  id                          :bigint           not null, primary key
#  creator                     :integer
#  creator_damage              :integer          default(0), not null
#  loser_damage                :integer
#  loser_modifier              :integer
#  opponent                    :integer
#  opponent_damage             :integer          default(0), not null
#  winner                      :string
#  winner_damage               :integer          default(0), not null
#  winner_modifier             :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  rock_paper_scissors_game_id :bigint           not null
#
# Indexes
#
#  index_game_rounds_on_rock_paper_scissors_game_id  (rock_paper_scissors_game_id)
#
# Foreign Keys
#
#  fk_rails_...  (rock_paper_scissors_game_id => rock_paper_scissors_games.id)
#
class GameRound < ApplicationRecord
  belongs_to :rock_paper_scissors_game

  scope :with_both_moved, -> { where.not(opponent: nil, creator: nil)}
  scope :with_winner, -> { where.not(winner: nil) }

  enum winner_modifier: { increased_damage: 0, critical: 1, miss: 2 }
  # If this enum is updated, validate RockPaperScissorsGameDecorator
  enum loser_modifier: { heal: 0, counter: 1 }

  def both_moved?
    creator.present? && opponent.present?
  end
  alias_method :both_moved, :both_moved?

  def draw?
    both_moved? && winner.blank?
  end

  def loser
    return unless winner

    winner == 'creator' ? 'opponent' : 'creator'
  end

  def creator_weapon
    @creator_weapon ||= rock_paper_scissors_game.cached_weapons[rock_paper_scissors_game.creator_id][creator]
  end

  def opponent_weapon
    @opponent_weapon ||= rock_paper_scissors_game.cached_weapons[rock_paper_scissors_game.opponent_id][opponent]
  end
end
