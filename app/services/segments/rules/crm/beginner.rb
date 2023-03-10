class Segments::Rules::Crm::Beginner < Segments::Rules::Crm::Base
  def call
    paid_games_count.zero? && free_games_count.zero?
  end
end
