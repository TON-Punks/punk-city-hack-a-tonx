class Segments::Rules::Fetcher
  MAPPING = {
    Segments::Crm => {
      Segments::Crm::BEGINNER => Segments::Rules::Crm::Beginner,
      Segments::Crm::REGULAR_FREE => Segments::Rules::Crm::RegularFree,
      Segments::Crm::REGULAR_PAYER => Segments::Rules::Crm::RegularPayer,
      Segments::Crm::CHAMPION_FREE => Segments::Rules::Crm::ChampionFree,
      Segments::Crm::CHAMPION_PAYER => Segments::Rules::Crm::ChampionPayer,
      Segments::Crm::INACTIVE => Segments::Rules::Crm::Inactive
    },
    Segments::FreeTournament => {
      Segments::FreeTournament::PARTICIPANT => Segments::Rules::FreeTournament::Participant
    }
  }.freeze

  class << self
    def call(user, segment_type)
      MAPPING.fetch(segment_type).detect { |_name, rule| rule.call(user) }&.first
    end
  end
end
