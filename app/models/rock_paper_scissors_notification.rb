# == Schema Information
#
# Table name: rock_paper_scissors_notifications
#
#  id                          :bigint           not null, primary key
#  locale                      :string           default("en"), not null
#  temporary                   :boolean          default(TRUE), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  chat_id                     :string
#  inline_message_id           :string
#  message_id                  :string
#  rock_paper_scissors_game_id :bigint           not null
#
# Indexes
#
#  index_rock_paper_scissors_notifications_on_game_id  (rock_paper_scissors_game_id)
#
# Foreign Keys
#
#  fk_rails_...  (rock_paper_scissors_game_id => rock_paper_scissors_games.id)
#
class RockPaperScissorsNotification < ApplicationRecord
  belongs_to :rock_paper_scissors_game

  scope :temporary, -> { where(temporary: true) }
end
