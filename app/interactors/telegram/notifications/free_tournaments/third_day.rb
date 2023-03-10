class Telegram::Notifications::FreeTournaments::ThirdDay < Telegram::Notifications::FreeTournaments::Base
  def call
    send_notification(
      text_key: "notifications.free_tournaments.third_day.text",
      button_key: "notifications.free_tournaments.third_day.button",
      action: "#free_tournaments##leaderboard:"
    )
  end
end
