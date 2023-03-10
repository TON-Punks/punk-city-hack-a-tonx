class BlackMarket::Purchases::Callbacks::EmojiPack < BlackMarket::Purchases::Callbacks::Base
  NOTIFICATIONS_CHAT_ID = -1001616613465

  def call
    I18n.with_locale(:ru) do
      Telegram::Notifications::InternalAdmin.call(
        admin_chat_id: NOTIFICATIONS_CHAT_ID,
        message: I18n.t("admin.notifications.emoji_pack_purchased.common",
          punk_number: punk.number,
          punk_url: punk.animated_punk_url,
          payment_amount: purchase.payment_amount,
          payment_currency: purchase.payment_method.upcase,
          transaction_info: transaction_info_message
        )
      )
    end
  end

  private

  def transaction_info_message
    return '' unless purchase.ton_payment_method?

    I18n.t("admin.notifications.emoji_pack_purchased.ton",
      user_transaction: purchase.data["user_transaction_hash"],
      seller_transaction: purchase.data["seller_transaction_hash"]
    )
  end

  def punk
    @punk ||= Punk.find_by(number: purchase.data["punk_number"])
  end
end
