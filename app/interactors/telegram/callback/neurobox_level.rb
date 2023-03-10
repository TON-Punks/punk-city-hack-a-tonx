class Telegram::Callback::NeuroboxLevel < Telegram::Callback
  include TonHelper

  def menu
    text = I18n.t("neurobox_level.caption", levels_left: mission.levels_left, neuroboxes_count: neuroboxes_count)
    buttons = []

    if neuroboxes_count.positive?
      if to_nano(Lootboxes::ProcessPrepaid::TON_FEE) > user.wallet.virtual_balance
        buttons << [error_button]
      else
        buttons << [open_button]
      end
    end

    buttons << [menu_button]

    send_or_update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
  end

  def show_balance_error
    text = I18n.t("neurobox_level.errors.not_enough_ton", balance: user.wallet.pretty_balance)
    buttons = [[back_button]]

    send_or_update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
  end

  private

  def neuroboxes_count
    user.lootboxes.lite_series.created.count
  end

  def mission
    @mission ||= user.neurobox_level_missions.running.first_or_create!
  end

  def photo
    File.open(TelegramImage.path("missions/neurobox_for_level.png"))
  end

  def open_button
    TelegramButton.new(text: I18n.t("notifications.neurobox_for_level.button"), web_app: { url: "#{IntegrationsConfig.frontend_url}/lite-lootboxes?token=#{user.auth_token}" })
  end

  def error_button
    TelegramButton.new(text: I18n.t("notifications.neurobox_for_level.button"), data: "#neurobox_level##show_balance_error:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#neurobox_level##menu:")
  end

  def menu_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#mission##menu:")
  end
end
