class Telegram::Callback::ZeyaMembershipCardPurchase < Telegram::Callback
  def menu
    buttons = [
                [TelegramButton.new(text: I18n.t("black_market.zeya_membership_card.menu.button"), data: "#zeya_membership_card_purchase##purchase:")],
                [back_button]
              ]

    text = I18n.t("black_market.zeya_membership_card.menu.caption", provided_wallet: user.pretty_provided_wallet, praxis_price: product.current_price)

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: photo, text: text, buttons: buttons)
    end
  end

  def purchase
    buttons = [
                [back_button]
              ]

    result = ::BlackMarket::PurchaseZeyaMembershipCard.call(user: user)

    text = if result.success?
             I18n.t("black_market.zeya_membership_card.purchase.caption")
           else
             result.error_message
           end

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: photo, text: text, buttons: buttons)
    end
  end

  private

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::ZEYA_MEMBERSHIP_CARD)
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#zeya##trade_ship:")
  end

  def photo
    File.open(Rails.root.join("telegram_assets/images/black_market/zeya_membership.png"))
  end
end
