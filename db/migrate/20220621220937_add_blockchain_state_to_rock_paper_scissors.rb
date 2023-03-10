class AddBlockchainStateToRockPaperScissors < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :blockchain_state, :integer
  end
end
