class AddBotStrategyToRockPaperScissorsGames < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :bot_strategy, :string
  end
end
