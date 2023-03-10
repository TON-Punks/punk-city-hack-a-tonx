class AddPointsToUserFreeTournamentStatistic < ActiveRecord::Migration[6.1]
  def change
    add_column :user_free_tournament_statistics, :score, :integer, null: false, default: 0
    add_column :user_free_tournament_statistics, :position, :integer
    add_column :user_free_tournament_statistics, :reward, :integer
  end
end
