class Telegram::Notifications::FreeTournaments::UserLost < Telegram::Notifications::FreeTournaments::Base
  delegate :tournament, to: :context

  def call
    send_notification(
      text: I18n.t("notifications.free_tournaments.lost.text", place: place),
      button_key: "notifications.free_tournaments.lost.button",
      action: "#cyber_arena##menu:new_message=true"
    )
  end

  private

  def place
    tournament.statistic_for_user(user).position
  end

  def photo
    tournament.leaderboard_photo
  end
end
