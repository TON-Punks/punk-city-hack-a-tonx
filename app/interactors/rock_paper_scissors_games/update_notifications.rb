class RockPaperScissorsGames::UpdateNotifications
  include Interactor
  include TonHelper

  PAYOUT_RATIO = 1.8

  delegate :game, to: :context

  def call
    game.notifications.each do |notification|
      I18n.locale = notification.locale

      text = if game.started?
               I18n.t("notifications.#{game.bet_currency}_battle.started", game_bet: game.pretty_bet)
             elsif game.creator_won?
               creator_won_message
             elsif game.opponent_won?
               opponent_won_message
             elsif game.archived?
               I18n.t("notifications.#{game.bet_currency}_battle.game_unavailable")
             end

      args = { text: text, parse_mode: nil, reply_markup: { inline_keyboard: [] }.to_json }

      notification_args = if notification.inline_message_id
                            args.merge(inline_message_id: notification.inline_message_id)
                          else
                            args.merge(chat_id: notification.chat_id, message_id: notification.message_id)
                          end

      TelegramApi.edit_message(notification_args)
    end
  end

  private

  def won_ton
    @won_ton ||= from_nano(game.bet * PAYOUT_RATIO)
  end

  def won_usd_for_ton
    @won_usd_for_ton ||= TonPriceConverter.new(won_ton).convert_to_usd
  end

  def praxis_won_amount
    (game.bet * PAYOUT_RATIO).to_i
  end

  def creator_won_message
    if game.ton_bet_currency?
      I18n.t("notifications.#{game.bet_currency}_battle.creator_won",
        creator_id: game.creator.identification,
        opponent_id: game.opponent.identification,
        won: won_ton,
        usd: won_usd_for_ton)
    elsif game.praxis_bet_currency?
      I18n.t("notifications.praxis_battle.creator_won",
        creator_id: game.creator.identification,
        opponent_id: game.opponent.identification,
        won: praxis_won_amount)
    end
  end

  def opponent_won_message
    if game.ton_bet_currency?
      I18n.t("notifications.ton_battle.opponent_won",
        opponent_id: game.opponent.identification,
        creator_id: game.creator.identification,
        won: won_ton,
        usd: won_usd_for_ton)
    elsif game.praxis_bet_currency?
      I18n.t("notifications.praxis_battle.opponent_won",
        opponent_id: game.opponent.identification,
        creator_id: game.creator.identification,
        won: praxis_won_amount)
    end
  end
end
