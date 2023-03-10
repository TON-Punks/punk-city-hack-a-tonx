class AddBetCurrencyToRockPaperScissorsGames < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :bet_currency, :integer

    reversible do |dir|
      dir.up do
        execute "UPDATE rock_paper_scissors_games SET bet_currency = 0 WHERE bet > 0"
      end
    end
  end
end
