class FreeTournaments::Leaderboard::StatisticsData
  include Interactor

  delegate :page, :tournament, to: :context

  PAGE_SIZE = 10

  def call
    leaderboard = leaderboard_for_page(page)

    context.last_page = (leaderboard_for_page(page + 1).first.presence || {})[:reward].to_i.zero? ||
                        (leaderboard.last.presence || {})[:reward].to_i.zero?

    context.leaderboard = leaderboard
  end

  private

  def leaderboard_for_page(page)
    statistics(page).map { |stats| presented_stats(stats) }
  end

  def statistics(current_page)
    tournament.user_free_tournament_statistics
              .where.not(position: nil)
              .by_position
              .offset(PAGE_SIZE * current_page)
              .limit(PAGE_SIZE)
  end

  def presented_stats(stats)
    {
      position: stats.position,
      username: presented_username(stats.user),
      score: stats.score,
      games_won: stats.games_won,
      games_lost: stats.games_lost,
      reward: stats.reward
    }
  end

  def presented_username(user)
    username = raw_username(user)
    username.length > 11 ? "#{username.first(11)}…" : username
  end

  def raw_username(user)
    return "PUNK ##{user.punk.number}" if user.punk

    user.identification
  end
end
