class Telegram::Callback::Notification < Telegram::Callback
  def menu
    buttons = [
      [TelegramButton.new(text: toggle_button_text, data: "#notification##toggle:")],
      [to_profile_button]
    ]

    text = I18n.t("profile.notifications.caption")

    if message_to_update?
      update_inline_keyboard(photo: punk_city_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: punk_city_photo, text: text, buttons: buttons)
    end
  end

  def toggle
    user.update!(notifications_disabled_at: user.notifications_disabled_at.present? ? nil : Time.zone.now)

    text = I18n.t("common.done")

    if message_to_update?
      update_inline_keyboard(photo: punk_city_photo, caption: text, buttons: [to_profile_button])
    else
      send_inline_keyboard(photo: punk_city_photo, text: text, buttons: [to_profile_button])
    end
  end

  private

  def toggle_button_text
    user.notifications_disabled_at.present? ? I18n.t("profile.notifications.button_enable") : I18n.t("profile.notifications.button_disable")
  end

  def to_profile_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#profile##menu:")
  end
end
