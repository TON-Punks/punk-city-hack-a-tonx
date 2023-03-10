class Segments::Rules::Crm::Inactive < Segments::Rules::Crm::Base
  def call
    (free_games_count + paid_games_count > 0) && !played_last_month?
  end
end
