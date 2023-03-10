class AddInlineMessageIdToRockPaperScissorsNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_notifications, :inline_message_id, :string
  end
end
