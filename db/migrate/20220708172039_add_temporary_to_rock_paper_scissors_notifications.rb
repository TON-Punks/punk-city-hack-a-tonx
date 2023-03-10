class AddTemporaryToRockPaperScissorsNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_notifications, :temporary, :boolean, default: true, null: false
  end
end
