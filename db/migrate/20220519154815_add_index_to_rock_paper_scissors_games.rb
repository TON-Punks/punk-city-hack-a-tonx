class AddIndexToRockPaperScissorsGames < ActiveRecord::Migration[6.1]
  def change
    add_index(:rock_paper_scissors_games, :state)
  end
end
