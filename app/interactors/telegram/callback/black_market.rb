class Telegram::Callback::BlackMarket < Telegram::Callback
  def menu
    buttons = if user.provided_wallet.present?
                [
                  [TelegramButton.new(text: I18n.t("black_market.menu.buttons.ask_wallet"), data: "#black_market##ask_wallet:")],
                  [TelegramButton.new(text: I18n.t("black_market.menu.buttons.initial_lootbox"), data: "#initial_lootbox_purchase##menu:")],
                  [TelegramButton.new(text: I18n.t("black_market.menu.buttons.golden_floppy"), data: "#golden_floppy_purchase##menu:")],
                  [TelegramButton.new(text: I18n.t("black_market.menu.buttons.ton_punks_purchase"), data: "#ton_punks_purchase##menu:")],
                  [TelegramButton.new(text: I18n.t("black_market.menu.buttons.animated_punk"), data: "#animated_punk_purchase##menu:")],
                  [TelegramButton.new(text: I18n.t('black_market.menu.buttons.neuropunk'), data: "#neuropunk##menu:")],
                  [TelegramButton.new(text: I18n.t('black_market.menu.buttons.emoji_pack'), data: "#emoji_pack##menu:")],
                  [TelegramButton.new(text: I18n.t('black_market.menu.buttons.offer_new_product'), data: "#offer_new_product##menu:")],
                  [back_trade_button]
                ]
              else
                return ask_wallet
              end

    text = I18n.t("black_market.menu.caption", praxis: user.praxis_balance, provided_wallet: user.pretty_provided_wallet)

    if message_to_update? && callback_arguments['new_message'] != 'true'
      update_inline_keyboard(photo: black_market_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: black_market_photo, text: text, buttons: buttons)
    end
  end

  def ask_wallet(text = I18n.t("black_market.ask_wallet.labels.ask"))
    user.update!(next_step: "#black_market##save_wallet:")

    button = if user.provided_wallet.blank?
               back_trade_button
             else
               back_button
             end

    if message_to_update? && callback_arguments['new_message'] != 'true'
      update_inline_keyboard(photo: black_market_photo, caption: text, buttons: [button])
    else
      send_photo_with_keyboard(photo: black_market_photo, caption: text, buttons: [button])
    end
  end

  def save_wallet
    address = telegram_request.message.text.strip

    if ![48, 68].include?(address.size)
      return ask_wallet(I18n.t("black_market.ask_wallet.errors.invalid_wallet_format"))
    end

    user.update!(provided_wallet: address, next_step: nil)

    text = I18n.t("black_market.ask_wallet.labels.success")

    if message_to_update?
      update_inline_keyboard(photo: black_market_photo, caption: text, buttons: [back_button])
    else
      send_photo_with_keyboard(photo: black_market_photo, caption: text, buttons: [back_button])
    end
  end

  private

  def black_market_photo
    File.open(TelegramImage.path("black_market.png"))
  end

  def back_trade_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#menu##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#black_market##menu:")
  end
end
