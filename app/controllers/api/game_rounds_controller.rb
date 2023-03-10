class Api::GameRoundsController < Api::BaseController
  def index
    game_rounds = game.game_rounds

    render json: GameRoundSerializer.render(game_rounds, root: :game_rounds)
  end

  def create
    move = RockPaperScissorsGame::NAME_TO_MOVE[params[:move].to_sym]
    return head :unprocessable_entity if game.started? || move.blank?

    game_round = game.make_move!(from: current_user, move: move)

    render json: GameRoundSerializer.render(game_round, root: :game_round)
  end

  private

  def game
    @rock_paper_scissors_game ||= RockPaperScissorsGame.find_by(id: params[:rock_paper_scissors_game_id])
  end
end
