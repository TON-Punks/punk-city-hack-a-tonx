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
class GameRoundSerializer < ApplicationSerializer
  identifier :id

  fields :winner, :creator_damage, :opponent_damage

  association :creator_weapon, blueprint: Inventory::ItemSerializer
  association :opponent_weapon, blueprint: Inventory::ItemSerializer
end
