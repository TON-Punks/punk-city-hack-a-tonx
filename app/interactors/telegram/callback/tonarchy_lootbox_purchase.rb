class Telegram::Callback::TonarchyLootboxPurchase < Telegram::Callback
  def menu
    buttons = [
                [TelegramButton.new(text: I18n.t("black_market.tonarchy_lootbox.menu.buttons.ton"), data: "#tonarchy_lootbox_purchase##purchase:pay=ton")],
                [TelegramButton.new(text: I18n.t("black_market.tonarchy_lootbox.menu.buttons.praxis", praxis_price: product.current_price), data: "#tonarchy_lootbox_purchase##purchase:pay=praxis")],
                [back_button]
              ]

    count = user.black_market_purchases.where(black_market_product: product).count
    text = I18n.t("black_market.tonarchy_lootbox.menu.caption", lootboxes_count: count)

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: photo, text: text, buttons: buttons)
    end
  end

  def purchase
    buttons = [[back_button]]
    result = ::BlackMarket::PurchaseTonarchyLootbox.call(user: user, pay_method: callback_arguments['pay'].to_s)

    text = if result.success?
       I18n.t("black_market.tonarchy_lootbox.purchase.caption")
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
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::TONARCHY_LOOTBOX)
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#tonarchy##menu:")
  end

  def photo
    File.open(Rails.root.join("telegram_assets/images/black_market/tonarchy_lootbox.png"))
  end
end
