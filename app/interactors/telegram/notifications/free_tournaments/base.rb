class Telegram::Notifications::FreeTournaments::Base < Telegram::Base
  def call
    raise NotImplementedError
  end

  private

  def send_notification(button_key:, action:, text_key: nil, text: nil)
    caption = text.presence || I18n.t(text_key)
    buttons = [TelegramButton.new(text: I18n.t(button_key), data: action)]
    send_inline_keyboard(text: caption, buttons: buttons, photo: photo)
  end

  def photo
    File.open(TelegramImage.path("free_tournaments/menu.png"))
  end
end
