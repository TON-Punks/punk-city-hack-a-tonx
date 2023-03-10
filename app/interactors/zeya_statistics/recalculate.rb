class ZeyaStatistics::Recalculate
  include Interactor

  delegate :statistic, to: :context
  delegate :user, to: :statistic

  def call
    statistic.update(top_score: user.zeya_games.where.not(score: nil).by_score.first&.score.to_i)
  end
end
