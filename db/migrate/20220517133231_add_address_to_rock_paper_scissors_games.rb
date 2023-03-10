class AddAddressToRockPaperScissorsGames < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :address, :string
  end
end
