class FreeTournaments::CalibrationStats
  include Interactor

  TON_GAMES_REQUIRED = 3
  PRAXIS_GAMES_REQUIRED = 5
  FREE_GAMES_REQUIRED = 7

  delegate :user, to: :context

  def call
    context.stats = {
      ton_games_left: ton_games_left,
      praxis_games_left: praxis_games_left,
      free_games_left: free_games_left
    }
  end

  private

  def ton_games_left
    TON_GAMES_REQUIRED - won_ton_games_count
  end

  def praxis_games_left
    PRAXIS_GAMES_REQUIRED - won_praxis_games_count
  end

  def free_games_left
    FREE_GAMES_REQUIRED - won_free_games_count
  end

  def won_ton_games_count
    @won_ton_games_count ||= won_games_count(:with_ton_bet)
  end

  def won_praxis_games_count
    @won_praxis_games_count ||= won_games_count(:with_praxis_bet)
  end

  def won_free_games_count
    @won_free_games_count ||= won_games_count(:free)
  end

  def won_games_count(battles_scope)
    won_created_games(battles_scope) + won_participated_games(battles_scope)
  end

  def won_created_games(battles_scope)
    user.created_rock_paper_scissors_games
        .public_send(battles_scope)
        .where(state: :creator_won)
        .where(created_at: tournament.start_at..)
        .count
  end

  def won_participated_games(battles_scope)
    user.participated_rock_paper_scissors_games
        .public_send(battles_scope)
        .where(state: :opponent_won)
        .where(created_at: tournament.start_at..)
        .count
  end

  def tournament
    @tournament ||= FreeTournament.running
  end
end
