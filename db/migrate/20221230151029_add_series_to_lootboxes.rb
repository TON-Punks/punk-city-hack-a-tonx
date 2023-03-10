class AddSeriesToLootboxes < ActiveRecord::Migration[6.1]
  def change
    add_column :lootboxes, :series, :text, null: false
    add_column :lootboxes, :result, :jsonb
  end
end
