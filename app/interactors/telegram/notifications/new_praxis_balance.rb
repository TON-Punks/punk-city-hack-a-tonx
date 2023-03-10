class Telegram::Notifications::NewPraxisBalance < Telegram::Base
  def call
    wallet = user.praxis_wallet
    text = I18n.t("notifications.praxis_balance_updated", wallet_balance: wallet.balance)
    send_message(text)
  end
end
