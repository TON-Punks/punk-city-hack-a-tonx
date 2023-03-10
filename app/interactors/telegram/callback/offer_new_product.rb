class Telegram::Callback::OfferNewProduct < Telegram::Callback
  OFFER_PRODUCTS_CHAT_ID = -1001622070683

  def menu
    user.update!(next_step: nil) if user.next_step
    text = I18n.t("black_market.offer_new_product.menu.caption")

    buttons = [
      [TelegramButton.new(text: I18n.t("black_market.offer_new_product.menu.button"), data: "#offer_new_product##ask_offer:")],
      [back_black_market_button]
    ]

    if message_to_update?
      update_inline_keyboard(photo: black_market_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: black_market_photo, text: text, buttons: buttons)
    end
  end

  def ask_offer
    user.update!(next_step: "#offer_new_product##submit_offer:")

    text = I18n.t("black_market.offer_new_product.ask_offer.caption")

    if message_to_update?
      update_inline_keyboard(photo: black_market_photo, caption: text, buttons: [back_button])
    else
      send_photo_with_keyboard(photo: black_market_photo, caption: text, buttons: [back_button])
    end
  end

  def submit_offer
    user.update!(next_step: nil)

    TelegramApi.forward_message(
      chat_id: OFFER_PRODUCTS_CHAT_ID,
      from_chat_id: user.chat_id,
      message_id: telegram_request.message.message_id
    )

    text = I18n.t("black_market.offer_new_product.submit_offer.caption")

    if message_to_update?
      update_inline_keyboard(photo: black_market_photo, caption: text, buttons: [back_black_market_button])
    else
      send_photo_with_keyboard(photo: black_market_photo, caption: text, buttons: [back_black_market_button])
    end
  end

  private

  def black_market_photo
    File.open(TelegramImage.path("black_market.png"))
  end

  def back_black_market_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#black_market##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#offer_new_product##menu:")
  end
end
