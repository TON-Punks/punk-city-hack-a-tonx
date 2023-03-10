# == Schema Information
#
# Table name: rock_paper_scissors_games
#
#  id                  :bigint           not null, primary key
#  address             :string
#  bet                 :bigint           default(0), not null
#  bet_currency        :integer
#  blockchain_state    :integer
#  boss                :text
#  bot                 :boolean          default(FALSE), not null
#  bot_strategy        :string
#  creator_experience  :integer
#  current_weapons     :json             not null
#  opponent_experience :integer
#  rounds              :jsonb            not null
#  state               :integer          default("created"), not null
#  visibility          :integer          default("public"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :bigint           not null
#  opponent_id         :bigint
#
# Indexes
#
#  index_rock_paper_scissors_games_on_creator_id   (creator_id)
#  index_rock_paper_scissors_games_on_opponent_id  (opponent_id)
#  index_rock_paper_scissors_games_on_state        (state)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (opponent_id => users.id)
#
class RockPaperScissorsGameSerializer < ApplicationSerializer
  identifier :id

  fields :bet_currency, :state
  field  :pretty_bet, name: :bet

  association :creator, blueprint: UserProfileSerializer
  association :opponent, blueprint: UserProfileSerializer
end
