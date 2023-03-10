class AddMissingFieldsToRockPaperScissorsGame < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_games, :visibility, :integer, default: 0, null: false
  end
end
