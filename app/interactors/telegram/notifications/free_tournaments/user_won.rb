class Telegram::Notifications::FreeTournaments::UserWon < Telegram::Notifications::FreeTournaments::Base
  delegate :tournament, to: :context

  def call
    send_notification(
      text: I18n.t("notifications.free_tournaments.won.text", praxis: statistic.reward, place: statistic.position),
      button_key: "notifications.free_tournaments.won.button",
      action: "#bank##menu:"
    )
  end

  private

  def statistic
    @statistic ||= tournament.statistic_for_user(user)
  end

  def photo
    tournament.leaderboard_photo
  end
end
