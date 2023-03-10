class Telegram::Notifications::ChatRepRewarded < Telegram::Base
  delegate :rep, :exp, to: :context

  def call
    text = I18n.t("notifications.chat_rep_rewarded", rep: rep.abs, rep_sign: rep.positive? ? '+' : '-', exp: exp)
    send_message(text)
  end
end
