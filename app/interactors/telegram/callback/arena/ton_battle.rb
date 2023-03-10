class Telegram::Callback::Arena::TonBattle < Telegram::Callback::Arena::Base
  include TonHelper

  delegate :wallet, to: :user

  def menu
    if wallet.balance.to_i.zero?
      text = I18n.t("cyber_arena.with_ton.top_up")
      buttons = [
        TelegramButton.new(text: I18n.t("menu.wallet"), data: "#wallet##menu:"),
        back_menu_button
      ]

      update_inline_keyboard(photo: start_fight_photo, caption: text, buttons: buttons)
    else
      text = I18n.t("cyber_arena.labels.ton_description")
      buttons = [
        [TelegramButton.new(text: I18n.t("cyber_arena.with_ton.find_game"), data: action_data("find_game:"))],
        [TelegramButton.new(
          text: I18n.t("cyber_arena.with_ton.create_game"),
          data: action_data("choose_game_visibility:")
        )],
        [back_menu_button]
      ]

      send_or_update_inline_keyboard(photo: start_fight_photo, caption: text, buttons: buttons)
    end
  end

  def create_game
    text = I18n.t("cyber_arena.labels.create_game_with_ton", max_bet: wallet.pretty_max_bet)
    user.update!(next_step: action_data("set_bet:visibility=#{callback_arguments["visibility"]}"))
    send_message(text)
  end

  def set_bet
    game = RockPaperScissorsGame.new(creator: user, visibility: callback_arguments["visibility"], bet_currency: :ton)
    bet = telegram_request.message.text
    game.parse_bet(bet.strip.to_f) if bet.present?

    if game.bet < RockPaperScissorsGame::MIN_TON_BET || !game.can_pay?(user)
      text = I18n.t("cyber_arena.errors.invalid_game_bet", max_bet: wallet.pretty_max_bet)
      send_photo_with_keyboard(photo: start_fight_photo, caption: text, buttons: [back_button])
    elsif (from_nano(game.bet).to_f * 10).to_i % 5 != 0
      text = I18n.t("cyber_arena.errors.invalid_game_bet_multiplier")
      send_photo_with_keyboard(photo: start_fight_photo, caption: text, buttons: [back_button])
    else
      user.update!(next_step: nil) if user.next_step

      result = RockPaperScissorsGames::CreateGame.call(game: game)

      if result.joined
        start_fight(result)
      else
        wait_for_game(result.game)
        send_matchmaking_invites
      end
    end
  end

  private

  def find_games_scope
    RockPaperScissorsGame.public_visibility.with_ton_bet.created.order(bet: :desc)
  end

  def find_game_name(game)
    "#{game.pretty_bet} TON"
  end

  def wait_with_proposed_game_caption_message(game, proposed_game)
    I18n.t(
      "cyber_arena.wait_for_game.ton_battle.proposal.caption",
      game_bet: game.pretty_bet,
      offer_game_bet: proposed_game.pretty_bet
    )
  end

  def wait_with_proposed_game_accept_message(game)
    I18n.t("cyber_arena.wait_for_game.ton_battle.proposal.accept", game_bet: game.pretty_bet)
  end

  def wait_with_proposed_game_reject_message
    I18n.t("cyber_arena.wait_for_game.ton_battle.proposal.reject")
  end

  def wait_for_game_type_message(game)
    I18n.t("cyber_arena.wait_for_game.ton_battle.plain", game_bet: game.pretty_bet)
  end
end
