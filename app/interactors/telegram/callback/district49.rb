class Telegram::Callback::District49 < Telegram::Callback
  def menu
    caption = I18n.t('district49.menu.caption')

    buttons = [
      [TelegramButton.new(text: I18n.t("district49.buttons.toadz"), data: "#toadz##menu:")],
      [TelegramButton.new(text: I18n.t("district49.buttons.zeya"), data: "#zeya##menu:")],
      [TelegramButton.new(text: I18n.t("district49.buttons.tonarchy"), data: "#tonarchy##menu:")],
      [to_main_menu_button]
    ]

    update_inline_keyboard(photo: punk_city_photo, caption: caption, buttons: buttons)
  end
end
