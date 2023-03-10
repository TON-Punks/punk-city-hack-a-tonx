class CreateUserFreeTournamentStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :user_free_tournament_statistics do |t|
      t.belongs_to :free_tournament, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :games_won, null: false, default: 0
      t.integer :games_lost, null: false, default: 0

      t.timestamps
    end

    add_index :user_free_tournament_statistics, %i[free_tournament_id user_id], unique: true,
      name: :index_on_free_tournament_statistics
  end
end
