class Telegram::Callback::TonPunksPurchase < Telegram::Callback
  COLLECTION_URL = "https://getgems.io/collection/EQAo92DYMokxghKcq-CkCGSk_MgXY5Fo1SPW20gkvZl75iCN"

  def menu
    buttons = [
      [TelegramButton.new(text: I18n.t("black_market.ton_punks_purchase.menu.buttons.buy"), url: COLLECTION_URL)],
      [back_market_button]
    ]

    text = I18n.t('black_market.ton_punks_purchase.menu.caption')

    if message_to_update?
      update_inline_keyboard(photo: collection_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: collection_photo, text: text, buttons: buttons)
    end
  end

  private

  def collection_photo
    File.open(Rails.root.join("telegram_assets/images/black_market/ton_punks/collection-#{rand(1..3)}.png"))
  end

  def back_market_button(new_message: false)
    data = "#black_market##menu:"
    data += "new_message=true" if new_message

    TelegramButton.new(text: I18n.t("common.back"), data: data)
  end
end
