class Crm::TelegramService < Telegram::Base
  def send_notification(text:, buttons:, photo:)
    send_inline_keyboard(text: text, buttons: buttons, photo: photo)
  end
end
