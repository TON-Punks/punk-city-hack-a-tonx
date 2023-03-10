class AddBetToRockPaperScissorsGames < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :bet, :bigint, null: false, default: 0
  end
end
