class Telegram::Callback::ResidentialBlock < Telegram::Callback
  def menu
    text = I18n.t("residential_block.caption")
    buttons = [
      [inventory_button],
      [missions_button],
      [repair_weapon_button],
      [back_button]
    ]

    send_or_update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
  end

  private

  def photo
    File.open(TelegramImage.path("residential_block.png"))
  end

  def inventory_button
    TelegramButton.new(text: I18n.t("residential_block.buttons.inventory"), web_app: { url: "#{IntegrationsConfig.frontend_url}?token=#{user.auth_token}" })
  end

  def missions_button
    TelegramButton.new(text: I18n.t("residential_block.buttons.missions"), data: "#mission##menu:")
  end

  def repair_weapon_button
    TelegramButton.new(text: I18n.t("residential_block.buttons.workshop"), data: "#workshop##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#menu##menu:")
  end
end
