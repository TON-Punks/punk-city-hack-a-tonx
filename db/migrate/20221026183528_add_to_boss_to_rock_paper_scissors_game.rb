class AddToBossToRockPaperScissorsGame < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :boss, :text
  end
end
