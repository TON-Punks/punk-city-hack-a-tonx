class AddWeaponsToRockPaperScissorsGames < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :current_weapons, :json, null: false, default: {}
  end
end
