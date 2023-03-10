class Telegram::Callback::Zeya < Telegram::Callback
  delegate :wallet, to: :user
  LEADERS_COUNT = 15
  PUNK_LEADERS_COUNT = 5

  def menu
    caption = I18n.t('zeya.menu.caption')

    buttons = [
      [TelegramButton.new(text: I18n.t('zeya.menu.buttons.win_nft'), data: '#zeya##win_nft:')],
      [TelegramButton.new(text: I18n.t('zeya.menu.buttons.more_info'), url: I18n.t('zeya.menu.channel_url'))],
      [to_main_menu_button]
    ]

    update_inline_keyboard(animation: menu_photo, caption: caption, buttons: buttons)
  end

  def win_nft
    caption = I18n.t('zeya.win_nft.caption')
    buttons = [
      [TelegramButton.new(text: I18n.t('zeya.win_nft.buttons.game'), data: '#zeya##game:')],
      [back_button]
    ]

    update_inline_keyboard(photo: win_nft_photo, caption: caption, buttons: buttons)
  end

  def leaderboard
    users = User.by_zeya_score.includes(:zeya_statistic)
    caption = generate_leaderboard_caption(users, LEADERS_COUNT)

    buttons = [back_button]

    update_inline_keyboard(photo: leaderboard_photo, caption: caption, buttons: buttons)
  end

  def punk_leaderboard
    users = User.joins(:punk).by_zeya_score.includes(:zeya_statistic)
    caption = generate_leaderboard_caption(users, PUNK_LEADERS_COUNT)

    buttons = [back_button]

    update_inline_keyboard(photo: punk_leaderboard_photo, caption: caption, buttons: buttons)
  end

  def game
    send_game('Zeya_in_Punkcity')
  end

  private

  def generate_leaderboard_caption(scope, count)
    caption = scope.limit(count).map.with_index do |u, i|
      "#{position_emoji(i, count)} `#{u.identification}` - #{u.zeya_statistic.top_score}"
    end.join("\n")

    if !caption.include?(user.identification)
      pos = scope.where(zeya_statistics: { top_score: (user.zeya_statistic.top_score + 1).. }).count
      extra_caption = "\n#{position_emoji(pos, count)}. `#{user.identification}` - #{user.zeya_statistic.top_score}"
      caption += "\n🛸🛸🛸" if pos > count
      caption += extra_caption
    end

    caption
  end

  def back_button
    TelegramButton.new(text: I18n.t('common.menu'), data: '#zeya##menu:')
  end

  def position_emoji(pos, max)
    case pos
    when 0 then '🥇'
    when 1 then '🥈'
    when 2 then '🥉'
    when 3...max then '🎗'
    else
      '⭐️'
    end
  end

  def menu_photo
    File.open(TelegramImage.path("zeya_1.png"))
  end

  def win_nft_photo
    File.open(TelegramImage.path("zeya_2.png"))
  end

  def leaderboard_photo
    File.open(TelegramImage.path("zeya_3.png"))
  end

  def punk_leaderboard_photo
    File.open(TelegramImage.path("zeya_4.png"))
  end

  def trade_ship_photo
    File.open(TelegramImage.path("zeya_5.png"))
  end

  def membership_card_product
    @membership_card_product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::ZEYA_MEMBERSHIP_CARD)
  end
end
