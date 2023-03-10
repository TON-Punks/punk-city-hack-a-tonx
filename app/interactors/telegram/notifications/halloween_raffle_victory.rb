class Telegram::Notifications::HalloweenRaffleVictory < Telegram::Base
  def call
    text = I18n.t("notifications.halloween_raffle_victory")
    send_message(text)
  end
end
