class FreeTournaments::RecalculateStatistics
  include Interactor

  FIRST_PLACE_REWARD_MULTIPLIER = 0.2

  def call
    context.fail! if tournament.blank?
    context.fail! if statistics_ids.blank?

    update_positions
    update_rewards
  end

  private

  def update_positions
    UserFreeTournamentStatistic.connection.execute(<<-SQL)
      UPDATE user_free_tournament_statistics
      SET position = new_position
      FROM (
        SELECT id, ROW_NUMBER() OVER (ORDER BY score DESC) AS new_position
        FROM user_free_tournament_statistics
        WHERE id IN (#{statistics_ids.join(", ")})
      ) ranked
      WHERE user_free_tournament_statistics.id = ranked.id;
    SQL
  end

  def statistics_ids
    @statistics_ids ||= tournament.user_free_tournament_statistics.where(user: segment.users).pluck(:id)
  end

  def update_rewards
    first_place_reward = (tournament.prize_amount * FIRST_PLACE_REWARD_MULTIPLIER).floor
    q = 1 - (first_place_reward.to_f / tournament.prize_amount)
    reward = first_place_reward

    tournament.user_free_tournament_statistics.where.not(position: nil).order(position: :asc).each do |stat|
      stat.update(reward: reward)
      reward = (reward * q).floor
    end
  end

  def segment
    @segment ||= Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT)
  end

  def tournament
    @tournament ||= context.tournament.presence || FreeTournament.running
  end
end
