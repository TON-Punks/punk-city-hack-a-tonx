class AddMissingFieldsToGameRounds < ActiveRecord::Migration[6.1]
  def change
    add_column :game_rounds, :winner_modifier, :integer
    add_column :game_rounds, :loser_modifier, :integer
    add_column :game_rounds, :loser_damage, :integer
  end
end
