class Telegram::Notifications::NewZeyaExperience < Telegram::Base
  def call
    text = I18n.t("notifications.new_zeya_experience", exp: context.exp)
    send_message(text)
  end
end
