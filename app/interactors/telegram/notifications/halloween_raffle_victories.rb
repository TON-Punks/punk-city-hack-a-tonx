class Telegram::Notifications::HalloweenRaffleVictories < Telegram::Base
  CHAT_IDS = [-1001627286419, -1001724637974]

  delegate :user1, :user2, to: :context

  def call
    text = I18n.t("notifications.halloween_raffle_victories",  user1: user1.identification, user2: user2.identification)

    I18n.with_locale(:ru) do
      CHAT_IDS.each do |chat_id|
        TelegramApi.send_message(chat_id: chat_id, text: text)
      end
    end
  end
end
