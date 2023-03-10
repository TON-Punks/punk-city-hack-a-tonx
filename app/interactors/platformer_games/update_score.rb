class PlatformerGames::UpdateScore
  include Interactor

  delegate :game, :score, to: :context

  def call
    return context.fail! if game.score.present?
    top_scores = User.where.not(platformer_statistics: { top_score: 0 }).
      by_platformer_score.
      limit(15).
      pluck('users.id, platformer_statistics.top_score')

    return unless game.update(score: score, finished_at: Time.current)

    new_top_score(score) if new_top_score?(top_scores, score)
    update_experience
  end

  private

  def update_experience
    game.increase_experience!

    game.user.with_locale do
      Telegram::Notifications::NewToadzExperience.call(user: game.user, exp: game.user_experience)
    end
  end

  def new_top_score?(top_scores, score)
    score > top_scores.map(&:last).min && !top_scores.map(&:first).include?(game.user_id)
  end

  def new_top_score(score)
    Telegram::Notifications::NewToadzLeader.call(user: game.user, score: score)
    game.user.recalculate_platformer_statistic!
  end
end
