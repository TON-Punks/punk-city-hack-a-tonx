class RepExperience::Organizer
  include Interactor::Organizer

  organize(
    RepExperience::CombotFetcher,
    RepExperience::CsvParser,
    RepExperience::BaseChangesCalculator,
    RepExperience::UsersDataProcessor,
    RepExperience::TopRewardsNotifier
  )
end
