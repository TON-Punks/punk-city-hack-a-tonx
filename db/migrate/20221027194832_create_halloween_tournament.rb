class CreateHalloweenTournament < ActiveRecord::Migration[6.1]
  def change
    Tournament.create(kind: :halloween, expires_at: 5.days.from_now.end_of_day + 4.hours, address: "EQCo0oZuZX08VJPRoFTURvRqSL9bKCHwW8bYLjitHW3LY_Nq")
  end
end
