class Telegram::Notifications::FreeTournaments::FirstDay < Telegram::Notifications::FreeTournaments::Base
  def call
    send_notification(
      text: I18n.t("notifications.free_tournaments.first_day.text", praxis: praxis_reward),
      button_key: "notifications.free_tournaments.first_day.button",
      action: "#free_tournaments##leaderboard:"
    )
  end

  private

  def praxis_reward
    FreeTournament.running.prize_amount
  end
end
