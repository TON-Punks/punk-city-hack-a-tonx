class Telegram::Callback::Tonarchy < Telegram::Callback
  def menu
    caption = I18n.t('tonarchy.menu.caption')

    buttons = [
      [TelegramButton.new(text: I18n.t('tonarchy.menu.buttons.game'), web_app: { url: 'https://game.tonarchy.online/'})],
      [TelegramButton.new(text: I18n.t('tonarchy.menu.buttons.pc'), url: 'https://game.tonarchy.online/')],
      [TelegramButton.new(text: I18n.t('tonarchy.menu.buttons.more_info'), url: I18n.t('tonarchy.menu.channel_url'))],

      [to_main_menu_button]
    ]

    update_inline_keyboard(animation: main_video, caption: caption, buttons: buttons)
  end

  private

  def back_button
    TelegramButton.new(text: I18n.t('common.menu'), data: '#tonarchy##menu:')
  end

  def main_video
    File.open(Rails.root.join("telegram_assets/videos/tonarchy_room.mp4"))
  end

  def leaderboard_video
    File.open(Rails.root.join("telegram_assets/videos/tonarchy_leaderboard.mp4"))
  end
end
