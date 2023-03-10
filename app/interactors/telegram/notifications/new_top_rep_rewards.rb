class Telegram::Notifications::NewTopRepRewards < Telegram::Base
  CHAT_IDS = {
    ru: [TelegramConfig.ru_cyber_arena_chat_id]
  }

  delegate :score, to: :context

  def call
    CHAT_IDS.each do |locale, chat_ids|
      I18n.with_locale(locale) do
        text = I18n.t("notifications.new_top_rep_rewards.title")

        text += score.map do |data|
          I18n.t("notifications.new_top_rep_rewards.user",
            user: data[:user].identification,
            rep: data[:rep_change].abs,
            rep_sign: data[:rep_change].positive? ? '+' : '-',
            exp: data[:exp_to_add]
          )
        end.join

        chat_ids.each do |chat_id|
          TelegramApi.send_message(chat_id: chat_id, text: text)
        end
      end
    end
  end
end
