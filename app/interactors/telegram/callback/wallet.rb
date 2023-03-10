class Telegram::Callback::Wallet < Telegram::Callback
  BUTTONS = %i[top_up bank buy_ton withdraw]

  CRYPTO_BOT_LINK = "http://t.me/CryptoBot?start=r-57887"

  delegate :wallet, to: :user

  def menu
    text = I18n.t("wallet.labels.info", wallet_address: wallet.pretty_address, wallet_balance: wallet.pretty_balance, praxis_balance: user.praxis_balance)

    buttons = [
      [TelegramButton.new(text: buttons_mapping[:top_up], data: "#wallet##top_up:")],
      [TelegramButton.new(text: buttons_mapping[:bank], data: "#bank##menu:")],
      [TelegramButton.new(text: buttons_mapping[:buy_ton], data: "#wallet##buy_ton:")],
      [TelegramButton.new(text: buttons_mapping[:withdraw], data: "#wallet##withdraw:")],
      [to_main_menu_button]
    ]

    user.update!(next_step: nil) if user.next_step

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: photo, caption: text, buttons: buttons)
    end
  end

  def buy_ton
    text = I18n.t("wallet.labels.buy_ton")
    link_word = text.split.last
    caption_offset = text.length - link_word.length

    caption_entities = [
      { type: "text_link", offset: caption_offset, length: link_word.length, url: CRYPTO_BOT_LINK }
    ]

    update_inline_keyboard(photo: photo, caption: text, buttons: [back_button], caption_entities: caption_entities, parse_mode: nil)
  end

  def top_up
    address = wallet.pretty_address
    text = I18n.t("wallet.labels.top_up")
    caption_entities = [ { type: 'pre', offset: text.length, length: address.length} ]
    text += "`#{address}`"

    update_inline_keyboard(photo: photo, caption: text, buttons: [back_button], caption_entities: caption_entities)
  end

  def withdraw(text = I18n.t("wallet.withdraw.labels.ask_wallet"))
    user.update!(next_step: "#wallet##withdraw_sum:")

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: [back_button])
    else
      send_photo_with_keyboard(photo: photo, caption: text, buttons: [back_button])
    end
  end

  def withdraw_sum(text = I18n.t("wallet.withdraw.labels.ask_sum"), request = nil )
    address = telegram_request.message.text.strip

    if request.blank? && ![48, 68].include?(address.size)
      return withdraw(I18n.t("wallet.withdraw.errors.invalid_wallet_format"))
    end

    request ||= WithdrawRequest.create(wallet: wallet, address: address)
    user.update!(next_step: "#wallet##withdraw_confirmation:request_id=#{request.id}")

    buttons = [
      [withdraw_everything_button(request.id, request.wallet.pretty_balance)],
      [back_button]
    ]

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: photo, caption: text, buttons: buttons)
    end
  end

  def withdraw_confirmation
    request = WithdrawRequest.find_by(id: callback_arguments['request_id'])

    amount = if callback_arguments['everything'] == 'true'
               request.update(amount: request.wallet.virtual_balance)
             else
               request.parse_amount!(telegram_request.message.text.strip)
             end

    if request.amount > request.wallet.virtual_balance.to_i
      return withdraw_sum(
        I18n.t("wallet.withdraw.errors.insufficient_funds", max_sum: request.wallet.pretty_virtual_balance),
        request
      )
    end

    if request.amount <= 0
      return withdraw_sum(I18n.t("wallet.withdraw.errors.invalid_number"), request)
    end

    buttons = [
      TelegramButton.new(text: I18n.t("common.confirm"), data: "#wallet##confirm:request_id=#{request.id}"),
      back_button
    ]

    text = I18n.t("wallet.withdraw.labels.confirmation", amount: request.pretty_amount, address: request.address)
    user.update!(next_step: nil)

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: photo, caption: text, buttons: buttons)
    end
  end

  def confirm
    request = WithdrawRequest.find_by(id: callback_arguments['request_id'])
    Wallets::Withdraw.call(withdraw_request: request)
    text = I18n.t("common.done")

    update_inline_keyboard(photo: photo, caption: text, buttons: [back_button])
  end

  def photo
    File.open(TelegramImage.path("wallet.png"))
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#wallet##menu:")
  end

  private

  def withdraw_everything_button(request_id, max_ton)
    TelegramButton.new(
      text: I18n.t("wallet.withdraw.labels.everything", ton: max_ton),
      data: "#wallet##withdraw_confirmation:request_id=#{request_id};everything=true"
    )
  end

  def buttons_mapping
    BUTTONS.each_with_object({}) do |button, hash|
      hash[button] = I18n.t("wallet.buttons.#{button}")
    end
  end
end
