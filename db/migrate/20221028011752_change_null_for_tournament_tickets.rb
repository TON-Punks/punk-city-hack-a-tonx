class ChangeNullForTournamentTickets < ActiveRecord::Migration[6.1]
  def change
    change_column_null :tournament_tickets, :platformer_game_id, true
  end
end
