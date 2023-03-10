class RockPaperScissorsGames::ScheduleBotGameCreation
  include Interactor
  include RedisHelper

  GAME_CREATION_ERROR = Class.new(StandardError)
  LAST_GAME_CREATED_KEY = "last_game_created".freeze
  NIGHT_HOURS = [23, 0, 1, 2, 3, 4, 5].freeze
  POSSIBLE_BETS = [500_000_000, 1_000_000_000].freeze

  def call
    return if redis.get(LAST_GAME_CREATED_KEY).to_i > max_delay.ago.to_i

    game = RockPaperScissorsGame.new(bet: POSSIBLE_BETS.sample, bet_currency: :ton)
    raise GAME_CREATION_ERROR unless game.can_pay?(creator)

    game.update!(creator: creator, bot: true, bot_strategy: bot_strategy)
    game.send_creation_notifications
    save_last_game_created_at
    RockPaperScissorsGames::CancelBotGameWorker.perform_in(10.minutes, game.id)
  end

  private

  def max_delay
    night_time? ? 4.hours : 2.5.hours
  end

  def night_time?
    NIGHT_HOURS.include?(Time.current.hour)
  end

  def creator
    @creator ||= User.find(TelegramConfig.bot_ids.sample)
  end

  def save_last_game_created_at
    redis.set(LAST_GAME_CREATED_KEY, Time.current.to_i)
  end

  def bot_strategy
    RockPaperScissorsGame::PAID_GAMES_STRATEGIES.sample
  end
end
