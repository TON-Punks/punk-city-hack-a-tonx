class Api::RockPaperScissorsGamesController < Api::BaseController
  def index
    if params[:bet_currency].blank?
      scope = RockPaperScissorsGame.created.where(bet_currency: params[:bet_currency])

      render json: RockPaperScissorsGameSerializer.render(scope, root: :rock_paper_scissors_games)
    else
      head :unprocessable_entity
    end
  end

  def show
    render json: RockPaperScissorsGameSerializer.render(rock_paper_scissors_game, root: :rock_paper_scissors_game)
  end

  def create
    game = RockPaperScissorsGame.new(creator: current_user, bet_currency: params[:bet_currency])
    game.parse_bet(params[:bet].strip.to_f)

    if game.bet < RockPaperScissorsGame::MIN_TON_BET || !game.can_pay?(current_user)
      result = RockPaperScissorsGames::CreateGame.call(game: game)

      render json: RockPaperScissorsGameSerializer.render(game, root: :rock_paper_scissors_game)
    else
      head :unprocessable_entity, error: { error_message: I18n.t("cyber_arena.errors.invalid_game_bet", max_bet: user.wallet.pretty_max_bet)}
    end
  end

  def destroy
    if rock_paper_scissors_game.created? && rock_paper_scissors_game.creator == current_user
      rock_paper_scissors_game.destroy!
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  private

  def rock_paper_scissors_game
    @rock_paper_scissors_game ||= RockPaperScissorsGame.find_by(id: params[:id])
  end
end
