class CreateRockPaperScissorsNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :rock_paper_scissors_notifications do |t|
      t.string :chat_id
      t.belongs_to :rock_paper_scissors_game, null: false, foreign_key: true, index: { name: 'index_rock_paper_scissors_notifications_on_game_id' }
      t.string :message_id

      t.timestamps
    end
  end
end
