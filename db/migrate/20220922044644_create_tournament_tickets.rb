class CreateTournamentTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :tournament_tickets do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :tournament, null: true, foreign_key: true
      t.belongs_to :platformer_game, null: true, foreign_key: true
      t.integer :state, default: 0, null: false

      t.timestamps
    end
  end
end
