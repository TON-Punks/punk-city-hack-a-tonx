class ZeyaGamesController < ApplicationController
  def create
    user = User.find_by!(chat_id: params[:chat_id])
    game = user.zeya_games.create
    user.update_current_session!

    render json: { id: game.id }
  end

  def update
    return head :ok

    game = ZeyaGame.find(params[:id])
    result = ZeyaGames::UpdateScore.call(game: game, score: params[:score].to_i)

    if result.success?
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
