class Telegram::Callback::Language < Telegram::Callback
  def menu
    buttons = [I18n.available_locales.map do |locale|
      TelegramButton.new(text: I18n.t("language.#{locale}"), data: "#language##set_language:language=#{locale}")
    end]

    buttons << [to_profile_button] if user.locale?

    text = I18n.t("language.choose_language")

    if message_to_update?
      update_inline_keyboard(photo: punk_city_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: punk_city_photo, text: text, buttons: buttons)
    end
  end

  def set_language
    user.update!(locale: callback_arguments["language"])
    I18n.locale = user.locale

    text = I18n.t("common.done")

    if user.onboarded?
      if message_to_update?
        update_inline_keyboard(photo: punk_city_photo, caption: text, buttons: [to_profile_button])
      else
        send_inline_keyboard(photo: punk_city_photo, text: text, buttons: [to_profile_button])
      end
    else
      Telegram::Callback::Onboarding.call(user: user, telegram_request: telegram_request, step: 'step1')
    end
  end

  private

  def to_profile_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#profile##menu:")
  end
end
