class Telegram::Callback::Onboarding < Telegram::Callback
  def step1
    text = I18n.t("onboarding.step1.caption")
    photo = File.open(TelegramImage.path("pic1.png"))
    buttons = [
      [TelegramButton.new(text: I18n.t("onboarding.step1.button"), data: "#onboarding##step2:")],
      [TelegramButton.new(text: I18n.t("onboarding.step1.skip_onboarding_button"), data: "#onboarding##skip_onboarding:")]
    ]
    send_photo_with_keyboard(caption: text, photo: photo, buttons: buttons)
  end

  def step2
    text = I18n.t("onboarding.step2.caption")
    photo = File.open(TelegramImage.path("pic2.png"))
    buttons = [TelegramButton.new(text: I18n.t("onboarding.step2.button"), data: "#onboarding##step3:")]
    update_inline_keyboard(caption: text, photo: photo, buttons: buttons)
  end

  def step3
    text = I18n.t("onboarding.step3.caption")
    photo = File.open(TelegramImage.path("pic3.png"))
    buttons = [TelegramButton.new(text: I18n.t("onboarding.step3.button"), data: "#onboarding##step4:")]
    update_inline_keyboard(caption: text, photo: photo, buttons: buttons)
  end

  def step4
    text = I18n.t("onboarding.step4.caption")
    photo = File.open(TelegramImage.path("pic4.png"))
    buttons = [
      [TelegramButton.new(text: I18n.t("onboarding.step4.button_battle"), data: "#cyber_arena##menu:")],
      [TelegramButton.new(text: I18n.t("onboarding.step4.button_menu"), data: "#menu##menu:")]
    ]
    user.update(onboarded: true)
    update_inline_keyboard(caption: text, photo: photo, buttons: buttons)
  end

  def skip_onboarding
    user.update(onboarded: true)
    Telegram::Callback::Menu.call(user: user, telegram_request: telegram_request, step: :menu)
  end
end
