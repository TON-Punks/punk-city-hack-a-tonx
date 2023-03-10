class Telegram::Callback::FreeTournament < Telegram::Callback
  def menu
    if user_participates_in_tournament?
      show_menu_screen
    else
      show_calibration_screen
    end
  end

  def leaderboard
    buttons = [leaderboard_navigation_buttons, [back_button]].compact

    text = I18n.t("free_tournaments.leaderboard.caption",
      start_date: formatted_date(tournament.start_at),
      end_date: formatted_date(tournament.finish_at),
      participants_count: participants_count,
      prize_amount: tournament.prize_amount,
      position: user_statistic.position,
      score: user_statistic.score,
      reward: user_statistic.reward,
      games_count: user_statistic.games_count,
      games_won: user_statistic.games_won,
      games_lost: user_statistic.games_lost)

    send_or_update_inline_keyboard(
      photo: leaderboard_photo(callback_arguments["page"].to_i),
      caption: text,
      buttons: buttons
    )
  end

  private

  def user_participates_in_tournament?
    segment.users.where(id: user.id).any?
  end

  def show_menu_screen
    buttons = [
      [cyber_arena_button],
      [
        TelegramButton.new(
          text: I18n.t("free_tournaments.menu.buttons.leaderboard"), data: "#free_tournaments##leaderboard:"
        )
      ],
      [back_menu_button]
    ]

    caption = I18n.t("free_tournaments.menu.caption", prize: tournament.prize_amount)

    send_or_update_inline_keyboard(photo: photo, caption: caption, buttons: buttons)
  end

  def show_calibration_screen
    buttons = [[back_menu_button]]

    caption = I18n.t("free_tournaments.calibration.caption",
      ton_battles_left: calibration_stats[:ton_games_left],
      praxis_battles_left: calibration_stats[:praxis_games_left],
      free_battles_left: calibration_stats[:free_games_left],
      prize_amount: tournament.prize_amount)

    send_or_update_inline_keyboard(photo: photo, caption: caption, buttons: buttons)
  end

  def leaderboard_navigation_buttons
    page = callback_arguments["page"].to_i
    data = FreeTournaments::Leaderboard::StatisticsData.call(tournament: tournament, page: page)

    [].tap do |buttons|
      buttons << leaderboard_back_button(page) if page.positive?
      buttons << leaderboard_forward_button(page) unless data.last_page
    end
  end

  def leaderboard_back_button(page)
    TelegramButton.new(
      text: I18n.t("free_tournaments.leaderboard.buttons.backward", from: page_size * (page - 1) + 1,
        to: page_size * page),
      data: "#free_tournaments##leaderboard:page=#{page - 1}"
    )
  end

  def leaderboard_forward_button(page)
    TelegramButton.new(
      text: I18n.t("free_tournaments.leaderboard.buttons.forward", from: page_size * (page + 1) + 1,
        to: page_size * (page + 2)),
      data: "#free_tournaments##leaderboard:page=#{page + 1}"
    )
  end

  def page_size
    FreeTournaments::Leaderboard::StatisticsData::PAGE_SIZE
  end

  def cyber_arena_button
    TelegramButton.new(text: I18n.t("menu.cyber_arena"), data: "#cyber_arena##menu:")
  end

  def user_statistic
    @user_statistic ||= tournament.statistic_for_user(user)
  end

  def photo
    File.open(TelegramImage.path("free_tournaments/menu.png"))
  end

  def leaderboard_photo(page)
    tournament.leaderboard_photo(page)
  end

  def participants_count
    segment.users.count
  end

  def formatted_date(date)
    date.strftime("%d/%m/%Y")
  end

  def calibration_stats
    @calibration_stats ||= FreeTournaments::CalibrationStats.call(user: user).stats
  end

  def tournament
    @tournament ||= ::FreeTournament.running
  end

  def segment
    @segment ||= Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT)
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#free_tournaments##menu:")
  end

  def back_menu_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#menu##menu:")
  end
end
