class Api::External::StonfiAirdropsController < ActionController::API
  def show
    return chat_id_blank if params[:chat_id].blank?

    user = User.find_by(chat_id: params[:chat_id])
    return user_not_found if user.blank?

    ton_battles_count = games_count(user)

    render json: { completed: ton_battles_count.positive?, ton_battles_count: ton_battles_count }
  end

  private

  def games_count(user)
    created_games(user) + participated_games(user)
  end

  def created_games(user)
    user.created_rock_paper_scissors_games
        .with_ton_bet
        .public_visibility
        .where(state: [:creator_won, :opponent_won])
        .where(created_at: start_time..)
        .count
  end

  def participated_games(user)
    user.participated_rock_paper_scissors_games
        .with_ton_bet
        .public_visibility
        .where(state: [:creator_won, :opponent_won])
        .where(created_at: start_time..)
        .count
  end

  def start_time
    Time.at(1678270669)
  end

  def user_not_found
    render json: { error: "user not found" }, status: :bad_request
  end

  def chat_id_blank
    render json: { error: "parameter chat_id is blank" }, status: :bad_request
  end
end
