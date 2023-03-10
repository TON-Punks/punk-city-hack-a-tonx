class Telegram::Notifications::Lootboxes::NeuroboxLevelReceived < Telegram::Base
  def call
    caption = I18n.t("notifications.neurobox_for_level.caption")
    buttons = [
      [
        TelegramButton.new(
          text: I18n.t("notifications.neurobox_for_level.button"),
          web_app: { url: "#{IntegrationsConfig.frontend_url}/lite-lootboxes?token=#{user.auth_token}" }
        )
      ],
      [TelegramButton.new(text: I18n.t("residential_block.buttons.missions"), data: "#mission##menu:")],
      [TelegramButton.new(text: I18n.t("common.menu"), data: "#menu##menu:")]
    ]

    send_inline_keyboard(text: caption, buttons: buttons, photo: photo)
  end

  private

  def photo
    File.open(TelegramImage.path("missions/completed.png"))
  end
end
