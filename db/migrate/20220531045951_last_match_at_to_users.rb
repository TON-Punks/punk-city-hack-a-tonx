class LastMatchAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_match_at, :datetime, index: true
  end
end
