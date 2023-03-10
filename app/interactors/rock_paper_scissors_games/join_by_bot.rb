class RockPaperScissorsGames::JoinByBot
  include Interactor

  JoinError = Class.new(StandardError)
  NoAvailableBotsError = Class.new(StandardError)

  delegate :game_id, to: :context

  def call
    return unless game_exists?
    raise NoAvailableBotsError.new(message: fetched_bot_result.error) unless fetched_bot_result.success?

    if join_game_result.success?
      perform_fight
    else
      raise JoinError unless join_game_result.game&.free?
    end
  end

  private

  def game_exists?
    RockPaperScissorsGame.find_by(id: game_id).present?
  end

  def perform_fight
    Telegram::Callback::Fight.call(
      user: joined_game.creator,
      game: joined_game,
      versus_image: join_game_result.creator_versus_image,
      step: :new_game
    )
  end

  def joined_game
    @joined_game ||= join_game_result.game
  end

  def join_game_result
    @join_game_result ||= RockPaperScissorsGames::JoinGame.call(
      user: find_bot,
      game_id: game_id,
      bot: true,
      bot_strategy: fetched_bot_result.bot_strategy
    )
  end

  def fetched_bot_result
    @fetched_bot_result ||= if RockPaperScissorsGame.find(game_id).free?
                              RockPaperScissorsGames::JoinByBots::FreeBotFetcher.call(game_id: game_id)
                            else
                              RockPaperScissorsGames::JoinByBots::PaidBotFetcher.call(game_id: game_id)
                            end
  end

  def find_bot
    User.find(fetched_bot_result.bot_id)
  end
end
