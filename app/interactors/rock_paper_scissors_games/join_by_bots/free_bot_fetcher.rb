class RockPaperScissorsGames::JoinByBots::FreeBotFetcher < RockPaperScissorsGames::JoinByBots::BaseBotFetcher
  def call
    context.bot_id = all_bot_ids.sample
    context.bot_strategy = RockPaperScissorsGame::FREE_GAMES_STRATEGIES.sample
  end

  private

  def all_bot_ids
    @all_bot_ids ||= TelegramConfig.bot_ids
  end
end
