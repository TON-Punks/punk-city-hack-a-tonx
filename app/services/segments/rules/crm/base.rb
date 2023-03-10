class Segments::Rules::Crm::Base
  class << self
    def call(user)
      new(user).call
    end
  end

  def initialize(user)
    @user = user
  end

  def call
    raise NotImplementedError
  end

  private

  attr_reader :user

  def played_last_month?
    user.created_rock_paper_scissors_games.where(created_at: 1.month.ago..).any? ||
      user.participated_rock_paper_scissors_games.where(created_at: 1.month.ago..).any?
  end

  def free_games_count
    @free_games_count ||= user.created_rock_paper_scissors_games.free.count +
                          user.participated_rock_paper_scissors_games.free.count
  end

  def paid_games_count
    @paid_games_count ||= user.created_rock_paper_scissors_games.with_ton_bet.count +
                          user.participated_rock_paper_scissors_games.with_ton_bet.count
  end
end
