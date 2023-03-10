class Telegram::Callback::Quest < Telegram::Callback
  BUTTONS = %i[toadz]
  delegate :wallet, to: :user

  def menu
    caption = ''
    buttons = [
      [TelegramButton.new(text: I18n.t("quest.buttons.toadz"), data: "#toadz##menu:")],
    ]
    buttons << [to_main_menu_button]

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: caption, buttons: buttons)
    else
      send_photo_with_keyboard(photo: photo, caption: caption, buttons: buttons)
    end
  end

  def photo
    File.open(TelegramImage.path("punk_city.png"))
  end
end
