class FreeTournaments::Finalize
  include Interactor

  def call
    FreeTournament.waiting_finish.find_each do |tournament|
      generate_final_leaderboard(tournament)

      ApplicationRecord.transaction do
        process_users(tournament)
        tournament.update!(state: :finished)
      end
    end
  end

  private

  def generate_final_leaderboard(tournament)
    FreeTournaments::RecalculateStatistics.call(tournament: tournament)
    FreeTournaments::Leaderboard::Generate.call(tournament: tournament)
  end

  def process_users(tournament)
    tournament.user_free_tournament_statistics.by_position.each do |stat|
      if stat.reward.to_i.positive?
        process_winning_user(tournament, stat)
      else
        process_lost_user(tournament, stat)
      end
    end
  end

  def process_winning_user(tournament, statistic)
    statistic.user.praxis_transactions.tournament_won.create!(quantity: statistic.reward)
    Telegram::Notifications::FreeTournaments::UserWon.call(tournament: tournament, user: statistic.user)
  end

  def process_lost_user(tournament, statistic)
    Telegram::Notifications::FreeTournaments::UserLost.call(tournament: tournament, user: statistic.user)
  end
end
