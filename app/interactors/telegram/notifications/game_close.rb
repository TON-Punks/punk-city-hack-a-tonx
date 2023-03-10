class Telegram::Notifications::GameClose < Telegram::Base
  FREE_GAME_CLOSE_MINUTES = 1.5
  PAID_GAME_CLOSE_MINUTES = 5

  delegate :free_game, :user_escaped, to: :context

  def call
    user.with_locale { send_photo_with_keyboard(photo: punk_city_photo, buttons: buttons, caption: notification_repilca) }
  end

  private

  def punk_city_photo
    File.open(TelegramImage.path("punk_city.png"))
  end

  def notification_repilca
    user_escaped ? I18n.t("notifications.close_game.escape_replica", minutes: game_close_time) : I18n.t("notifications.close_game.replicas").sample
  end

  def buttons
    [[new_game_button], [exit_button]]
  end

  def new_game_button
    TelegramButton.new(text: I18n.t("notifications.close_game.actions.new_game"), data: "#cyber_arena##menu:")
  end

  def exit_button
    TelegramButton.new(text: I18n.t("notifications.close_game.actions.exit_to_menu"), data: "#menu##menu:")
  end

  def game_close_time
    free_game ? FREE_GAME_CLOSE_MINUTES : PAID_GAME_CLOSE_MINUTES
  end
end
