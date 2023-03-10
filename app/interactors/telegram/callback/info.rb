class Telegram::Callback::Info < Telegram::Callback
  def menu
    buttons = [
      [button_for(:read, :cyber_arena)],
      [button_for(:cyber_arena), button_for(:battles)],
      [button_for(:black_market), button_for(:praxis_bank)],
      [button_for(:profile)],
      [button_for(:additional)],
      [main_menu_button]
    ]

    user.update(viewed_tutorial_at: Time.zone.now) if user.viewed_tutorial_at.blank?

    if message_to_update?
      update_inline_keyboard(photo: punk_city_photo, buttons: buttons)
    else
      send_photo_with_keyboard(photo: punk_city_photo, buttons: buttons)
    end
  end

  def cyber_arena
    buttons = [
      [button_for(:backward, :menu), button_for(:forward, :battles)],
      [main_menu_button]
    ]

    text = I18n.t("info.caption.cyber_arena")

    if message_to_update?
      update_inline_keyboard(photo: cyber_arena_photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: cyber_arena_photo, text: text, buttons: buttons)
    end
  end

  def battles
    buttons = [
      [button_for(:backward, :cyber_arena), button_for(:forward, :black_market)],
      [main_menu_button]
    ]

    text = I18n.t("info.caption.battles")

    if message_to_update?
      update_inline_keyboard(photo: battles_photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: battles_photo, text: text, buttons: buttons)
    end
  end

  def black_market
    buttons = [
      [button_for(:backward, :battles), button_for(:forward, :praxis_bank)],
      [main_menu_button]
    ]

    text = I18n.t("info.caption.black_market")

    if message_to_update?
      update_inline_keyboard(photo: black_market_photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: black_market_photo, text: text, buttons: buttons)
    end
  end

  def praxis_bank
    buttons = [
      [button_for(:backward, :black_market), button_for(:forward, :profile)],
      [main_menu_button]
    ]

    text = I18n.t("info.caption.praxis_bank")

    if message_to_update?
      update_inline_keyboard(photo: bank_photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: bank_photo, text: text, buttons: buttons)
    end
  end

  def profile
    buttons = [
      [button_for(:backward, :praxis_bank), button_for(:forward, :additional)],
      [main_menu_button]
    ]

    text = I18n.t("info.caption.profile")

    if message_to_update?
      update_inline_keyboard(photo: profile_photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: profile_photo, text: text, buttons: buttons)
    end
  end

  def additional
    buttons = [
      [button_for(:backward, :profile), button_for(:forward, :menu)],
      [main_menu_button]
    ]

    text = I18n.t("info.caption.additional")

    if message_to_update?
      update_inline_keyboard(photo: punk_city_photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: punk_city_photo, text: text, buttons: buttons)
    end
  end

  private

  def profile_photo
    user.profile_url
  end

  def battles_photo
    File.open(TelegramImage.path("cyber_arena.png"))
  end

  def cyber_arena_photo
    File.open(TelegramImage.path("choose.png"))
  end

  def black_market_photo
    File.open(TelegramImage.path("black_market.png"))
  end

  def bank_photo
    File.open(TelegramImage.path("bank.png"))
  end

  def button_for(button, item = nil)
    TelegramButton.new(text: I18n.t("info.buttons.#{button}"), data: "#info###{item.presence || button}:")
  end

  def main_menu_button
    TelegramButton.new(text: I18n.t("common.menu"), data: "#menu##menu:")
  end
end
