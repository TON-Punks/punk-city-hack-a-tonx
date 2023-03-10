class Telegram::Callback::EmojiPack < Telegram::Callback
  def menu
    page = callback_arguments['page'].to_i

    buttons = user_punks_scope.offset(6 * page).limit(6).map do |punk|
      [TelegramButton.new(text: I18n.t("black_market.emoji_pack.menu.punk_template", punk_number: punk.number), data: "#emoji_pack##request_add:punk_number=#{punk.number}")]
    end

    buttons << paginated_punks_navigation_menu(page) if buttons.any?
    buttons << [back_market_button]

    text = I18n.t('black_market.emoji_pack.menu.caption',
      provided_wallet: user.pretty_provided_wallet,
      praxis_price: product.current_price,
      ton_price: ton_price
    )

    if message_to_update?
      update_inline_keyboard(animation: animated_punk, caption: text, buttons: buttons)
    else
      send_inline_keyboard(animation: animated_punk, text: text, buttons: buttons)
    end
  end

  def request_add
    punk_number = callback_arguments['punk_number'].to_i
    punk = Punk.find_by(number: punk_number)

    buttons = [
      [TelegramButton.new(text: I18n.t("black_market.emoji_pack.request_add.button_ton", ton_price: ton_price), data: "#emoji_pack##confirm_add:punk=#{punk_number};pay=ton")],
      [TelegramButton.new(text: I18n.t("black_market.emoji_pack.request_add.button_praxis", praxis_price: product.current_price), data: "#emoji_pack##confirm_add:punk=#{punk_number};pay=praxis")],
      [back_select_button]
    ]

    text = I18n.t("black_market.emoji_pack.request_add.caption", number: punk_number)

    if message_to_update?
      update_inline_keyboard(animation: punk.animated_punk_url, caption: text, buttons: buttons)
    else
      send_inline_keyboard(animation: punk.animated_punk_url, text: text, buttons: buttons)
    end
  end

  def confirm_add
    punk_number = callback_arguments['punk'].to_i
    pay_method = callback_arguments['pay'].to_s

    punk = Punk.find_by(number: punk_number)
    buttons = []

    result = ::BlackMarket::PurchaseEmojiPack.call(user: user, punk: punk, pay_method: pay_method)

    if result.success?
      text = I18n.t("black_market.emoji_pack.confirm_add.added")
    else
      text = result.error_message
      buttons << [continue_button(punk)] if result.error_button == :continue
    end

    buttons << [back_market_button(new_message: true)]

    if message_to_update?
      update_inline_keyboard(animation: punk.animated_punk_url, caption: text, buttons: buttons)
    else
      send_inline_keyboard(animation: punk.animated_punk_url, text: text, buttons: buttons)
    end
  end

  private

  def continue_button(punk)
    TelegramButton.new(text: I18n.t("black_market.errors.low_ton_balance.button"), data: "#emoji_pack##request_add:punk_number=#{punk.number}")
  end

  def paginated_punks_navigation_menu(page)
    next_page_entries_present = user_punks_scope.offset(6 * (page + 1)).limit(6).any?

    buttons = []
    buttons << TelegramButton.new(text: "<", data: "#emoji_pack##menu:page=#{page - 1}") if page > 0
    buttons << TelegramButton.new(text: "•#{page + 1}•", data: "#emoji_pack##menu:page=#{page}")
    buttons << TelegramButton.new(text: ">", data: "#emoji_pack##menu:page=#{page + 1}") if next_page_entries_present

    buttons = [] if buttons.length == 1

    buttons
  end

  def animated_punk
    File.open(Rails.root.join("telegram_assets/images/black_market/punk_animate.gif"))
  end

  def user_punks_scope
    @user_punks_scope ||= Punk.where(owner: punk_owner_address, number: not_added_punks).order(:id)
  end

  def not_added_punks
    @not_added_punks ||= Punk.animated.pluck(:number) - already_added_punks
  end

  def already_added_punks
    @already_added_punks ||= BlackMarketPurchase.where(black_market_product: product).map do |purchase|
      purchase.data['punk_number']
    end
  end

  def punk_owner_address
    @punk_owner_address ||= user.provided_wallet.length == 64 ? user.provided_wallet : TonUtils.hex_address(user.provided_wallet)
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::EMOJI_PACK)
  end

  def ton_price
    @ton_price ||= ::BlackMarket::PurchaseEmojiPack::TON_FEE
  end

  def back_select_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#emoji_pack##menu:")
  end

  def back_market_button(new_message: false)
    data = "#black_market##menu:"
    data += "new_message=true" if new_message

    TelegramButton.new(text: I18n.t("common.back"), data: data)
  end
end
