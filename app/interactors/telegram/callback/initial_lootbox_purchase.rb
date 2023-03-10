class Telegram::Callback::InitialLootboxPurchase < Telegram::Callback
  def menu
    buttons = [[TelegramButton.new(text: I18n.t("black_market.initial_lootbox.menu.buttons.ton"), data: "#initial_lootbox_purchase##purchase:pay=ton")]]
    buttons << [open_button] if open_lootboxes.nonzero?
    buttons << [TelegramButton.new(text: I18n.t("common.back"), data: "#black_market##menu:")]

    ton_balance = user.wallet.pretty_balance
    text = I18n.t("black_market.initial_lootbox.menu.caption", open_lootboxes: open_lootboxes, ton_balance: ton_balance)

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: photo, text: text, buttons: buttons)
    end
  end

  def purchase
    result = ::BlackMarket::PurchaseInitialLootbox.call(user: user, pay_method: callback_arguments['pay'].to_s)

    text = if result.success?
      buttons = [
        [TelegramButton.new(text: I18n.t("black_market.initial_lootbox.menu.buttons.ton"), data: "#initial_lootbox_purchase##purchase:pay=ton")],
        [open_button],
        [back_button]
      ]

       I18n.t("black_market.initial_lootbox.purchase.caption",open_lootboxes: open_lootboxes)
     else
      buttons = [[back_button]]

      result.error_message
     end

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: photo, text: text, buttons: buttons)
    end
  end

  private

  def open_lootboxes
    @open_lootboxes ||= user.lootboxes.created.count
  end

  def open_button
    TelegramButton.new(text: I18n.t("black_market.initial_lootbox.menu.buttons.open"), web_app: { url: "#{IntegrationsConfig.frontend_url}/lootboxes?token=#{user.auth_token}" })
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::PUNK_LOOTBOX_INITIAL)
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#initial_lootbox_purchase##menu:")
  end

  def photo
    File.open(Rails.root.join("telegram_assets/images/black_market/initial_lootbox.png"))
  end
end
