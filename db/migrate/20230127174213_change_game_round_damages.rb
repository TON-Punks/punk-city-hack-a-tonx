class ChangeGameRoundDamages < ActiveRecord::Migration[6.1]
  def change
    add_column :game_rounds, :creator_damage, :integer, null: false, default: 0
    add_column :game_rounds, :opponent_damage, :integer, null: false, default: 0
  end
end
