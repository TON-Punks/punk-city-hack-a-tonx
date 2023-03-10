class Segments::Rules::Crm::ChampionPayer < Segments::Rules::Crm::Base
  def call
    paid_games_count.positive? && (free_games_count + paid_games_count >= 10) && played_last_month?
  end
end
