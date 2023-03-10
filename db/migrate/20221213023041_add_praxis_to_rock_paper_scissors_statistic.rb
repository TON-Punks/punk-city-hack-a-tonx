class AddPraxisToRockPaperScissorsStatistic < ActiveRecord::Migration[6.1]
  def change
    add_column :rock_paper_scissors_statistics, :praxis_won, :bigint
    add_column :rock_paper_scissors_statistics, :praxis_lost, :bigint
  end
end
