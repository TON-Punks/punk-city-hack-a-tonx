class AddRockPaperScissorsGameToTournamentTickets < ActiveRecord::Migration[6.1]
  def change
    add_reference :tournament_tickets, :rock_paper_scissors_game, null: true, foreign_key: true
  end
end
