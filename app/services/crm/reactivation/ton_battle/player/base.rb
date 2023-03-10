class Crm::Reactivation::TonBattle::Player::Base < Crm::Base
  private

  def matches_conditions?
    no_games_last_days?
  end

  def no_games_last_days?
    user.created_rock_paper_scissors_games.where(created_at: 10.days.ago..).blank? &&
      user.participated_rock_paper_scissors_games.where(created_at: 10.days.ago..).blank?
  end
end
