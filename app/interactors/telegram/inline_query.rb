class Telegram::InlineQuery < Telegram::Base
  include TonHelper
  def call
    games = user.created_rock_paper_scissors_games.created

    results = games.map do |game|
      bet = game.pretty_bet

      caption = I18n.t("notifications.#{game.bet_currency}_battle.info", game_bet: bet, creator_id: user.identification)
      deeplink = TelegramConfig.deeplink(Deeplinks::JoinGame.encode(game.id))
      buttons = [[TelegramButton.new(text: I18n.t("notifications.ton_battle.start"), url: deeplink)]]

      TelegramInlineResult.new(
        type: "article",
        id: game.id,
        thumb_url: photo_url,
        title: I18n.t("notifications.#{game.bet_currency}_battle.share.title"),
        description: I18n.t("notifications.#{game.bet_currency}_battle.share.description", bet: bet),
        input_message_content: { message_text: caption, parse_mode: "markdown" },
        reply_markup: {
          inline_keyboard: buttons
        }
      )
    end

    results << user_invitation if results.blank?

    TelegramApi.answer_inline_query(inline_query_id: inline_query_id, results: results.to_json)
  end

  private

  def user_invitation
    invite_data = Deeplinks::Invite.encode(user.id)
    deeplink = TelegramConfig.deeplink(invite_data)

    buttons = [[TelegramButton.new(text: I18n.t("notifications.invite.start"), url: deeplink)]]
    caption = I18n.t("notifications.invite.description", username: user.identification)

    TelegramInlineResult.new(
      type: "article",
      id: SecureRandom.uuid,
      thumb_url: photo_url,
      title: I18n.t("notifications.invite.title"),
      description: I18n.t("notifications.invite.description", username: user.identification),
      input_message_content: { message_text: caption, parse_mode: "markdown" },
      reply_markup: {
        inline_keyboard: buttons
      }
    )
  end

  def inline_query_id
    @inline_query_id ||= telegram_request.inline_query.id
  end

  def query
    telegram_request.inline_query.query
  end

  def photo_url
    "https://punk-metaverse.fra1.digitaloceanspaces.com/service/game_thumb.png"
  end
end
