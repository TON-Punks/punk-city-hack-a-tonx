class AddLootboxesCounterToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :free_lootboxes_rewarded_level, :integer, null: false, default: 0
  end
end
