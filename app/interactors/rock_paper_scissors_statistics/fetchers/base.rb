class RockPaperScissorsStatistics::Fetchers::Base
  include Interactor

  delegate :user, to: :context

  private

  def created_games
    user.created_rock_paper_scissors_games
  end

  def participated_games
    user.participated_rock_paper_scissors_games
  end
end
