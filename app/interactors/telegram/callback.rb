class Telegram::Callback < Telegram::Base
  delegate :callback_arguments, to: :context

  def call
    public_send(context.step)
  rescue => e
    raise e if Rails.env.test? || Rails.env.development?
    user&.unlock_game_creation!
    text = I18n.t("common.error")
    buttons = [to_main_menu_button]
    send_photo_with_keyboard(photo: punk_city_photo, buttons: buttons, caption: text)

    Honeybadger.notify(e)
  end

  private

  def to_main_menu_button
    TelegramButton.new(text: I18n.t("common.menu"), data: "#menu##menu:")
  end

  def punk_city_photo
    File.open(TelegramImage.path("punk_city.png"))
  end

  def send_or_update_inline_keyboard(**options)
    if can_update_message?
      update_inline_keyboard(options)
    else
      send_inline_keyboard(options.merge(text: options[:caption]).except(:caption))
    end
  end

  def can_update_message?
    message_to_update? && callback_arguments&.dig("new_message") != "true"
  end
end
