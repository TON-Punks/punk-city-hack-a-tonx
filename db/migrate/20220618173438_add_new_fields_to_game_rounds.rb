class AddNewFieldsToGameRounds < ActiveRecord::Migration[6.1]
  def change
    add_column :game_rounds, :winner_damage, :integer, default: 0, null: false
  end
end
