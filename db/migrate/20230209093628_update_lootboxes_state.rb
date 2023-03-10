class UpdateLootboxesState < ActiveRecord::Migration[6.1]
  def change
    remove_column :lootboxes, :blockchain_state
    add_column :lootboxes, :prepaid, :boolean, null: false, default: false
  end
end
