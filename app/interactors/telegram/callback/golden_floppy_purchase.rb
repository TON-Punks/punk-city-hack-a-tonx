class Telegram::Callback::GoldenFloppyPurchase < Telegram::Callback
  def menu
    buttons = [
      [TelegramButton.new(text: I18n.t("black_market.golden_floppy_purchase.menu.buttons.ton_buy"), data: "#golden_floppy_purchase##confirm:pay=ton")],
      [TelegramButton.new(text: I18n.t("black_market.golden_floppy_purchase.menu.buttons.praxis_buy", praxis_price: product.current_price), data: "#golden_floppy_purchase##confirm:pay=praxis")],
      [to_main_menu_button]
    ]

    text = I18n.t('black_market.golden_floppy_purchase.menu.caption',
      praxis_price: product.current_price,
      praxis_balance: user.praxis_balance,
      wallet_balance: user.wallet.pretty_virtual_balance
    )

    if message_to_update?
      update_inline_keyboard(animation: golden_floppy, caption: text, buttons: buttons)
    else
      send_inline_keyboard(animation: golden_floppy, text: text, buttons: buttons)
    end
  end

  def confirm
    pay_method = callback_arguments['pay'].to_s

    price = I18n.t("black_market.golden_floppy_purchase.confirm.purchase_types.#{pay_method}", price: product.current_price)
    text = I18n.t('black_market.golden_floppy_purchase.confirm.caption',
      price: price,
      wallet_address: user.provided_wallet,
    )

    buttons = [
      [TelegramButton.new(text: I18n.t("black_market.golden_floppy_purchase.confirm.buttons.purchase"), data: "#golden_floppy_purchase##purchase:pay=#{pay_method}")],
      [back_button]
    ]

    if message_to_update?
      update_inline_keyboard(animation: golden_floppy, caption: text, buttons: buttons)
    else
      send_inline_keyboard(animation: golden_floppy, text: text, buttons: buttons)
    end
  end

  def purchase
    pay_method = callback_arguments['pay'].to_s
    buttons = []

    result = ::BlackMarket::PurchaseGoldenFloppy.call(user: user, pay_method: pay_method)

    if result.success?
      text = I18n.t("black_market.golden_floppy_purchase.purchase.caption", wallet_address: user.provided_wallet)
      options = { animation: golden_floppy }
    else
      text = result.error_message
      buttons << [continue_button(pay_method)] if result.error_button == :continue
      options = { photo: punk_city_photo }
    end

    buttons << [back_button]

    if message_to_update?
      update_inline_keyboard(options.merge(caption: text, buttons: buttons))
    else
      send_inline_keyboard(options.merge(text: text, buttons: buttons))
    end
  end

  private

  def continue_button(pay_method)
    TelegramButton.new(text: I18n.t("black_market.errors.low_ton_balance.button"), data: "#golden_floppy_purchase##confirm:pay=#{pay_method}")
  end

  def golden_floppy
    File.open(Rails.root.join("telegram_assets/images/black_market/golden_floppy.gif"))
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::GOLDERN_FLOPPY)
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#golden_floppy_purchase##menu:")
  end
end
