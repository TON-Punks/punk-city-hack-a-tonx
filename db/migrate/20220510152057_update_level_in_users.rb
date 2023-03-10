class UpdateLevelInUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :expirience, :bigint, null: false, default: 0
  end
end
