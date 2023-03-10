class Telegram::Notifications::PunkNewOwner < Telegram::Base
  delegate :punk, to: :context

  def call
    text = I18n.t("notifications.punk_new_owner", punk_number: punk.number)
    send_message(text)
  end
end
