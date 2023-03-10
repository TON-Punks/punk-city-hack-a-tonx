class Telegram::Notifications::FreeTournaments::CalibrationPassed < Telegram::Notifications::FreeTournaments::Base
  def call
    send_notification(
      text: I18n.t("notifications.free_tournaments.calibration_passed.text"),
      button_key: "notifications.free_tournaments.calibration_passed.button",
      action: "#free_tournaments##menu:"
    )
  end
end
