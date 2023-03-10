class RockPaperScissorsGames::Matchmaking::SendInvites
  include Interactor
  include RedisHelper

  MIN_BET = 1

  def call
    RockPaperScissorsGame.created.public_visibility.where(bet_currency: %i[praxis ton]).each do |game|
      matching_game = find_matching_game(game)
      game.creator.with_locale do
        matching_game.present? ? send_invite(game, matching_game) : reset_invite(game)
      end
    end
  end

  private

  def send_invite(game, proposed_game)
    callback_class(game).call(
      user: game.creator,
      callback_arguments: { game: game, proposed_game: proposed_game }.with_indifferent_access,
      telegram_request: search_message_storage.telegram_request_for(game.id),
      step: :wait_with_proposed_game
    )
  end

  def reset_invite(game)
    callback_class(game).call(
      user: game.creator,
      callback_arguments: { game: game }.with_indifferent_access,
      telegram_request: search_message_storage.telegram_request_for(game.id),
      step: :wait_for_game
    )
  end

  def callback_class(game)
    game.ton_bet_currency? ? Telegram::Callback::Arena::TonBattle : Telegram::Callback::Arena::PraxisBattle
  end

  def find_matching_game(game)
    RockPaperScissorsGame
      .created
      .public_visibility
      .where(bet_currency: game.bet_currency)
      .where.not(id: game.id)
      .order(bet: :desc)
      .find_by(bet: MIN_BET..game.bet)
  end

  def search_message_storage
    @search_message_storage ||= RockPaperScissorsGames::Matchmaking::SearchMessageStorage.new
  end
end
