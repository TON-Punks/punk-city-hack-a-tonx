class Telegram::Notifications::RegularExchangeCompleted < Telegram::Base
  def call
    text = I18n.t("notifications.regular_exchange_completed", praxis: context.praxis)
    send_message(text)
  end
end
