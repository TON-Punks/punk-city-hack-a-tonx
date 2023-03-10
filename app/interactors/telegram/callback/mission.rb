class Telegram::Callback::Mission < Telegram::Callback
  def menu
    text = I18n.t("missions.caption")
    buttons = [
      [neurobox_button],
      [back_button]
    ]

    send_or_update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
  end

  private

  def photo
    File.open(TelegramImage.path("missions/terminal.png"))
  end

  def neurobox_button
    TelegramButton.new(text: I18n.t("missions.buttons.neurobox_level"), data: "#neurobox_level##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#residential_block##menu:")
  end
end
