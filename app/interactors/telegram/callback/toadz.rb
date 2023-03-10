class Telegram::Callback::Toadz < Telegram::Callback
  delegate :wallet, to: :user
  LEADERS_COUNT = 15

  def menu
    caption = I18n.t('toadz.menu.caption')
    buttons = [
      [TelegramButton.new(text: I18n.t('toadz.win_nft.buttons.game'), web_app: { url: "https://thesmartnik.github.io/test-toadz?chat_id=#{user.chat_id}" })],
      [TelegramButton.new(text: I18n.t('toadz.menu.buttons.more_info'), url: 'https://t.me/mutanttoadz')],
      [TelegramButton.new(text: I18n.t('common.menu'), data: '#menu##menu:')]
    ]

    update_inline_keyboard(animation: video, caption: caption, buttons: buttons)
  end

  private

  def back_button
    TelegramButton.new(text: I18n.t('common.menu'), data: '#toadz##menu:')
  end

  def video
    File.open(Rails.root.join("telegram_assets/videos/toadz_room.mp4"))
  end

  def leaderboard_photo
    File.open(TelegramImage.path("toadz_leaderboard.png"))
  end
end
