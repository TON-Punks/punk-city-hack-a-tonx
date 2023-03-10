class Telegram::Callback::ToadzTournament < Telegram::Callback
  delegate :wallet, to: :user
  LEADERS_COUNT = 15

  def menu
    caption = I18n.t('tournament.menu.info')
    buttons = [
      [TelegramButton.new(text: I18n.t('tournament.menu.buttons.novel'), web_app: { url: "https://ton-punks.github.io/toadz-novel/?chat_id=#{user.chat_id}" })],
      [TelegramButton.new(text: I18n.t('tournament.menu.buttons.participate'), data: '#toadz_tournament##participate:')],
      [TelegramButton.new(text: I18n.t('tournament.menu.buttons.leaderboard'), data: '#toadz_tournament##leaderboard:')],
      [TelegramButton.new(text: I18n.t('tournament.menu.buttons.training'), data: '#toadz_tournament##training:')],
      [back_button]
    ]

    update_inline_keyboard(animation: video, caption: caption, buttons: buttons)
  end

  def participate
    return send_game('toadz_tournament') if user.tournament_tickets.any?

    caption = I18n.t('tournament.participate.info', balance: wallet.pretty_virtual_balance, tickets_count: user.tournament_tickets.available.count)
    buttons = [
      [TelegramButton.new(text: I18n.t('tournament.participate.tickets', count: 1), data: '#toadz_tournament##buy_tickets:count=3')],
      [TelegramButton.new(text: I18n.t('tournament.participate.tickets', count: 9), data: '#toadz_tournament##buy_tickets:count=9')],
      [TelegramButton.new(text: I18n.t('tournament.participate.tickets', count: 15), data: '#toadz_tournament##buy_tickets:count=15')],
      [TelegramButton.new(text: I18n.t("profile.buttons.wallet"), data: "#wallet##menu:")],
      [back_button]
    ]

    update_inline_keyboard(animation: video, caption: caption, buttons: buttons)
  end

  def buy_tickets
    tickets_count = callback_arguments['count'].to_i
    result = TournamentTickets::Buy.call(user: user, count: tickets_count)

    if result.success?
      buttons = [
        [back_button]
      ]

      caption = I18n.t('tournament.participate.tickets_bought', count: tickets_count)
      update_inline_keyboard(animation: video, caption: caption, buttons: buttons)
    else
      error_buttons = [
        [TelegramButton.new(text: I18n.t("tournament.buy_tickets.buttons.top_up"), data: "#wallet##menu:")],
        [back_button]
      ]

      update_inline_keyboard(animation: video, caption: result.error_message, buttons: error_buttons)
    end
  end

  def leaderboard
    users = User.by_platformer_score.includes(:platformer_statistic).limit(LEADERS_COUNT)
    caption = users.map.with_index do |u, i|
      "#{i}. `#{u.identification}` - #{u.platformer_statistic.top_score}"
    end.join("\n")

    if !caption.include?(user.identification)
      pos = User.joins(:platformer_statistic).where(platformer_statistics: { top_score: (user.platformer_statistic.top_score + 1).. }).count
      extra_caption = "\n#{pos}. `#{user.identification}` - #{user.platformer_statistic.top_score}"
      caption += "\n..." if pos > LEADERS_COUNT
      caption += extra_caption
    end

    caption += "\n #{I18n.t('toadz.leaderboard.info')}"
    buttons = [back_button]

    update_inline_keyboard(photo: leaderboard_photo, caption: caption, buttons: buttons)
  end

  def training
    send_game('toadz_tournament')
  end

  private

  def back_button
    TelegramButton.new(text: I18n.t('common.menu'), data: '#toadz_tournament##menu:')
  end

  def video
    File.open(Rails.root.join("telegram_assets/videos/toadz_room.mp4"))
  end

  def leaderboard_photo
    File.open(TelegramImage.path("toadz_leaderboard.png"))
  end
end
