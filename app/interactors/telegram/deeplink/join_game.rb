class Telegram::Deeplink::JoinGame < Telegram::Deeplink
  def call
    result = RockPaperScissorsGames::JoinGame.call(deeplink_arguments.merge(user: user))
    if result.success?
      game = result.game
      creator_versus_image = result.creator_versus_image
      opponent_versus_image = result.opponent_versus_image
      Telegram::Callback::Fight.call(user: game.opponent, game: game, versus_image: opponent_versus_image,
        step: :new_game)
      Telegram::Callback::Fight.call(user: game.creator, game: game, versus_image: creator_versus_image,
        step: :new_game)
    else
      send_message(result.error) if result.error
      Telegram::Callback::Menu.call(user: user, telegram_request: telegram_request, step: "menu") if result.redirect
    end

    Referral.create(user: result.game.creator, referred: user) if create_referral?(result.game)
  end

  def create_referral?(game)
    game && !user.onboarded && user.referred_by.blank?
  end
end
