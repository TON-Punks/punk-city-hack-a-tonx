class AddUnsubscribedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :unsubscribed_at, :datetime
  end
end
