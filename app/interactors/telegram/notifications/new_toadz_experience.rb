class Telegram::Notifications::NewToadzExperience < Telegram::Base
  def call
    text = I18n.t("notifications.new_toadz_experience", exp: context.exp)
    send_message(text)
  end
end
