class Telegram::Callback::Arena::PraxisBattle < Telegram::Callback::Arena::Base
  include TonHelper

  delegate :praxis_wallet, to: :user

  def menu
    if praxis_wallet.balance.zero?
      text = I18n.t("cyber_arena.with_praxis.top_up")
      buttons = [
        back_menu_button
      ]

      update_inline_keyboard(photo: start_fight_photo, caption: text, buttons: buttons)
    else
      text = I18n.t("cyber_arena.labels.praxis_description")
      buttons = [
        [TelegramButton.new(
          text: I18n.t("cyber_arena.with_praxis.find_game"),
          data: action_data("find_game:")
        )],
        [TelegramButton.new(
          text: I18n.t("cyber_arena.with_praxis.create_game"),
          data: action_data("choose_game_visibility:")
        )],
        [back_menu_button]
      ]

      send_or_update_inline_keyboard(photo: start_fight_photo, caption: text, buttons: buttons)
    end
  end

  def create_game
    text = I18n.t("cyber_arena.labels.create_game_with_praxis", min_bet: RockPaperScissorsGame::MIN_PRAXIS_BET, max_bet: praxis_wallet.balance)
    user.update!(next_step: action_data("set_bet:visibility=#{callback_arguments["visibility"]}"))
    send_message(text)
  end

  def set_bet
    game = RockPaperScissorsGame.new(creator: user, visibility: callback_arguments["visibility"], bet_currency: :praxis)
    bet = telegram_request.message.text
    game.parse_praxis_bet(bet.strip.to_i)

    if game.bet < RockPaperScissorsGame::MIN_PRAXIS_BET || !game.can_pay?(user)
      text = I18n.t(
        "cyber_arena.errors.invalid_game_praxis_bet",
        min_bet: RockPaperScissorsGame::MIN_PRAXIS_BET,
        max_bet: praxis_wallet.balance
      )
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
    RockPaperScissorsGame.public_visibility.with_praxis_bet.created.order(bet: :desc)
  end

  def find_game_name(game)
    "#{game.bet} PRAXIS"
  end

  def wait_with_proposed_game_caption_message(game, proposed_game)
    I18n.t(
      "cyber_arena.wait_for_game.praxis_battle.proposal.caption",
      game_bet: game.bet,
      offer_game_bet: proposed_game.bet
    )
  end

  def wait_with_proposed_game_accept_message(game)
    I18n.t("cyber_arena.wait_for_game.praxis_battle.proposal.accept", game_bet: game.bet)
  end

  def wait_with_proposed_game_reject_message
    I18n.t("cyber_arena.wait_for_game.praxis_battle.proposal.reject")
  end

  def wait_for_game_type_message(game)
    I18n.t("cyber_arena.wait_for_game.praxis_battle.plain", game_bet: game.bet)
  end
end
