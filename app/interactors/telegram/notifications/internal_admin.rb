class Telegram::Notifications::InternalAdmin < Telegram::Base
  delegate :admin_chat_id, :message, to: :context

  def call
    TelegramApi.send_message(chat_id: admin_chat_id, text: message)
  end
end
