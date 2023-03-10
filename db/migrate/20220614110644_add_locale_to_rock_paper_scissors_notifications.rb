class AddLocaleToRockPaperScissorsNotifications < ActiveRecord::Migration[6.1]
  class RockPaperScissorsNotificationStub < ApplicationRecord
    self.table_name = :rock_paper_scissors_notifications
  end

  def change
    add_column :rock_paper_scissors_notifications, :locale, :string, null: false, default: 'en'

    RockPaperScissorsNotificationStub.update_all(locale: 'ru')
  end
end
