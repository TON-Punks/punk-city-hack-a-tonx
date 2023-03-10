class RockPaperScissorsGames::SendNotifications
  include Interactor

  DEFAULT_TEMPORARY = true

  CHAT_IDS_MAPPING = {
    ru: [
      { id: TelegramConfig.ru_cyber_arena_chat_id, probability: 1, condition: :send_to_cyber_arena_chat? },
      { id: TelegramConfig.sapiens_chat_id, probability: 1, condition: :send_to_sapiens_chat? }
    ],
    en: [{ id: TelegramConfig.en_cyber_arena_chat_id, probability: 1, condition: :send_to_cyber_arena_chat? }]
  }

  delegate :game, to: :context

  def call
    CHAT_IDS_MAPPING.each do |locale, chat_properties|
      I18n.with_locale(locale) do
        chat_properties.each do |chat_property|
          next if SecureRandom.rand > chat_property[:probability]
          next unless send(chat_property[:condition])

          response = send_message(chat_property[:id])
          next unless response.success?

          message_id = response.parsed_response.dig("result", "message_id")
          game.notifications.create!(
            chat_id: chat_property[:id],
            message_id: message_id,
            locale: locale,
            temporary: chat_property.key?(:temporary) ? chat_property[:temporary] : DEFAULT_TEMPORARY
          )
        end
      end
    end
  end

  private

  def send_message(chat_id)
    deeplink = TelegramConfig.deeplink(Deeplinks::JoinGame.encode(game.id))
    message = I18n.t("notifications.#{game.bet_currency}_battle.info", game_bet: game.pretty_bet,
      creator_id: game.creator.identification)

    buttons = [[TelegramButton.new(text: I18n.t("notifications.ton_battle.start"), url: deeplink)]]

    TelegramApi.send_message(
      chat_id: chat_id,
      text: message,
      reply_markup: { inline_keyboard: buttons }.to_json,
      parse_mode: nil
    )
  end

  def send_to_cyber_arena_chat?
    true
  end

  def send_to_sapiens_chat?
    if game.praxis_bet_currency?
      game.pretty_bet >= 300
    else
      true
    end
  end
end
