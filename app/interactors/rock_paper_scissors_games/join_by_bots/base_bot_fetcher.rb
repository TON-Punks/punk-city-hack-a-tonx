class RockPaperScissorsGames::JoinByBots::BaseBotFetcher
  include Interactor

  delegate :game_id, to: :context
end
