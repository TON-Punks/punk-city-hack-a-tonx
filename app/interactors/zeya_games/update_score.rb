class ZeyaGames::UpdateScore
  include Interactor

  delegate :game, :score, to: :context

  def call
    return context.fail! if game.score.present?
    top_scores = User.where.not(zeya_statistics: { top_score: 0 }).
      by_zeya_score.
      limit(15).
      pluck('users.id, zeya_statistics.top_score')


    return unless game.update!(score: score, finished_at: Time.current)
    update_experience
  end

  def update_experience
    game.increase_experience!

    game.user.with_locale do
      Telegram::Notifications::NewZeyaExperience.call(user: game.user, exp: game.user_experience)
    end
  end
end
