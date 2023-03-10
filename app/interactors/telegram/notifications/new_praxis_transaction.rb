class Telegram::Notifications::NewPraxisTransaction < Telegram::Base
  delegate :praxis_amount, :praxis_sender, to: :context

  def call
    text = I18n.t("notifications.new_praxis_transaction",
                  praxis_amount: praxis_amount,
                  praxis_sender: praxis_sender,
                  praxis_balance: user.praxis_balance
                )
    send_message(text)
  end
end
