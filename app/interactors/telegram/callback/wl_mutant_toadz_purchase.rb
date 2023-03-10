class Telegram::Callback::WlMutantToadzPurchase < Telegram::Callback
  def menu
    buttons = [
                [TelegramButton.new(text: I18n.t("black_market.wl_mutant_toadz.menu.button"), data: "#wl_mutant_toadz_purchase##purchase:")],
                [back_button]
              ]

    text = I18n.t("black_market.wl_mutant_toadz.menu.caption", provided_wallet: user.pretty_provided_wallet, praxis_price: product.current_price)

    if message_to_update?
      update_inline_keyboard(photo: wl_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: wl_photo, text: text, buttons: buttons)
    end
  end

  def purchase
    buttons = [
                [back_button]
              ]

    result = ::BlackMarket::PurchaseWlToadz.call(user: user)

    text = if result.success?
             I18n.t("black_market.wl_mutant_toadz.purchase.caption")
           else
             result.error_message
           end

    if message_to_update?
      update_inline_keyboard(photo: wl_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: wl_photo, text: text, buttons: buttons)
    end
  end

  private

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::WL_MUTANT_TOADZ)
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#black_market##menu:")
  end

  def wl_photo
    File.open(Rails.root.join("telegram_assets/images/black_market/toadz_wl.jpg"))
  end
end
