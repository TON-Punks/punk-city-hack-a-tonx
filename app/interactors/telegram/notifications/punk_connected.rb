class Telegram::Notifications::PunkConnected < Telegram::Base
  def call
    punk = user.punk
    text = I18n.t("notifications.punk_connected", punk_number: punk.number)
    send_message(text)
  end
end
