class Telegram::Notifications::ConnectedPunkStatistics < Telegram::Base
  CHAT_IDS = {
    ru: [TelegramConfig.holder_vol1_ru, TelegramConfig.ru_cyber_arena_chat_id],
    en: [TelegramConfig.en_cyber_arena_chat_id]
  }

  delegate :punks_count, :additional_punks_count, :praxis_reward, to: :context

  def call
    text = I18n.t("notifications.connected_punk_bonus.statistics", punks_count: punks_count,
      praxis_reward: praxis_reward, additional_punks_count: additional_punks_count)

    CHAT_IDS.each do |locale, chat_ids|
      I18n.with_locale(locale) do
        chat_ids.each do |chat_id|
          TelegramApi.send_message(chat_id: chat_id, text: text)
        end
      end
    end
  end
end
