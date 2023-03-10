class Telegram::Notifications::NewBalance < Telegram::Base
  def call
    wallet = user.wallet
    text = I18n.t("notifications.balance_updated", wallet_balance: wallet.pretty_balance)
    send_message(text)
  end
end
