class AddNotificationsDisabledAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :notifications_disabled_at, :datetime
  end
end
