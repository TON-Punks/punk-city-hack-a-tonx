class FreeTournaments::Contribute
  include Interactor

  delegate :user, :game, to: :context

  def call
    context.fail! if tournament.blank?
    context.fail! if user_bot_or_chat?
    context.fail! unless game.public_visibility?

    contribute_tournament_statistics
    FreeTournaments::CalibrationProcessor.call(user: user) unless user_participant?
  end

  private

  def user_bot_or_chat?
    user.bot? || user.chat_id.to_i.negative? || user.chat_id.to_i.zero?
  end

  def contribute_tournament_statistics
    tournament.user_free_tournament_statistics.where(user: user).first_or_create!.tap do |statistic|
      UserFreeTournamentStatistic.connection.execute(<<-SQL)
        UPDATE user_free_tournament_statistics
        SET score = GREATEST(0, score #{points_amount}), #{statistics_column} = (#{statistics_column} + 1)
        WHERE id = #{statistic.id}
      SQL
    end
  end

  def points_amount
    return "-2" unless won?

    if game.free?
      "+2"
    elsif game.praxis_bet_currency?
      "+5"
    elsif game.ton_bet_currency?
      "+7"
    else
      "+0"
    end
  end

  def statistics_column
    won? ? :games_won : :games_lost
  end

  def user_participant?
    segment.users.where(id: user.id).any?
  end

  def won?
    user == winner
  end

  def winner
    game.creator_won? ? game.creator : game.opponent
  end

  def segment
    @segment ||= Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT)
  end

  def tournament
    @tournament ||= FreeTournament.running
  end
end
