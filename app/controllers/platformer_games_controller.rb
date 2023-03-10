class PlatformerGamesController < ApplicationController
  def create
    user = User.find_by!(chat_id: params[:chat_id])
    user.update_current_session!
    game_attrs = {}

    if params[:tournament_id]
      tournament_ticket = TournamentTicket.find_by(id: params[:tournament_id], user_id: user.id)
      tournament_ticket&.used!
      game_attrs = game_attrs.merge(tournament_ticket: tournament_ticket)
    end

    game = user.platformer_games.create(game_attrs)

    render json: { id: game.id }
  end

  def update
    return head :ok

    game = PlatformerGame.find(params[:id])
    result = PlatformerGames::UpdateScore.call(game: game, score: params[:score].to_i)

    if result.success?
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
