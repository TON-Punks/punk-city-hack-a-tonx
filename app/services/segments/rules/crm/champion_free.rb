class Segments::Rules::Crm::ChampionFree < Segments::Rules::Crm::Base
  def call
    paid_games_count.zero? && (free_games_count >= 10) && played_last_month?
  end
end
