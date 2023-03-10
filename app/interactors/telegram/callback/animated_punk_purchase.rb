class Telegram::Callback::AnimatedPunkPurchase < Telegram::Callback
  def menu
    buttons = []

    if user_punks_scope.any?
      result = paginated_punks_menu

      punks_text = result[:caption]
      buttons << result[:buttons]
      page = result[:page]
    else
      punks_text = I18n.t("black_market.animated_punk.menu.punks_missing")
      page = 0
    end

    buttons << [TelegramButton.new(text: I18n.t("black_market.animated_punk.menu.button"), data: "#animated_punk_purchase##animate:page=#{page}")]
    buttons << [back_market_button]

    text = I18n.t('black_market.animated_punk.menu.caption',
      provided_wallet: user.pretty_provided_wallet,
      punks_list: punks_text,
      praxis_price: product.current_price
    )

    if message_to_update?
      update_inline_keyboard(animation: animated_punk, caption: text, buttons: buttons)
    else
      send_inline_keyboard(animation: animated_punk, text: text, buttons: buttons)
    end
  end

  def animate
    page = callback_arguments['page'].to_i

    buttons = user_punks_scope.offset(10 * page).limit(10).map do |punk|
      [TelegramButton.new(text: I18n.t("black_market.animated_punk.menu.punk_template", punk_number: punk.number), data: "#animated_punk_purchase##request_animate:punk_number=#{punk.number}")]
    end

    buttons << [back_market_button]

    text = I18n.t("black_market.animated_punk.animate.caption", praxis_price: product.current_price)

    if message_to_update?
      update_inline_keyboard(animation: animated_punk, caption: text, buttons: buttons)
    else
      send_inline_keyboard(animation: animated_punk, text: text, buttons: buttons)
    end
  end

  def request_animate
    punk_number = callback_arguments['punk_number'].to_i

    buttons = [
      [TelegramButton.new(text: I18n.t("black_market.animated_punk.request_animate.button_praxis", praxis_price: product.current_price), data: "#animated_punk_purchase##confirm_animate:punk=#{punk_number};pay=praxis")],
      [TelegramButton.new(text: I18n.t("black_market.animated_punk.request_animate.button_ton"), data: "#animated_punk_purchase##confirm_animate:punk=#{punk_number};pay=ton")],
      [back_animate_button]
    ]

    text = I18n.t("black_market.animated_punk.request_animate.caption")
    photo = selected_punk_photo(punk_number)

    if message_to_update?
      update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: photo, text: text, buttons: buttons)
    end
  end

  def confirm_animate
    punk_number = callback_arguments['punk'].to_i
    pay_method = callback_arguments['pay'].to_s
    punk = Punk.find_by(number: punk_number)
    buttons = []

    result = ::BlackMarket::PurchaseAnimatedPunk.call(user: user, punk: punk, pay_method: pay_method)

    if result.success?
      text = I18n.t("black_market.animated_punk.confirm_animate.animated", url: punk.animated_gif_punk_url)
      options = { animation: punk.animated_punk_url }
    else
      text = result.error_message
      buttons << [continue_button(punk)] if result.error_button == :continue
      options = { photo: punk_city_photo }
    end

    buttons << [back_market_button(new_message: true)]

    if message_to_update?
      update_inline_keyboard(options.merge(caption: text, buttons: buttons))
    else
      send_inline_keyboard(options.merge(text: text, buttons: buttons))
    end
  end

  private

  def continue_button(punk)
    TelegramButton.new(text: I18n.t("black_market.errors.low_ton_balance.button"), data: "#animated_punk_purchase##request_animate:punk_number=#{punk.number}")
  end

  def paginated_punks_menu
    page = callback_arguments['page'].to_i
    caption = user_punks_scope.offset(10 * page).limit(10).map do |punk|
      I18n.t("black_market.animated_punk.menu.punk_template", punk_number: punk.number)
    end.join

    next_page_entries_present = user_punks_scope.offset(10 * (page + 1)).limit(10).any?

    buttons = []
    buttons << TelegramButton.new(text: "<", data: "#animated_punk_purchase##menu:page=#{page - 1}") if page > 0
    buttons << TelegramButton.new(text: "•#{page + 1}•", data: "#animated_punk_purchase##menu:page=#{page}")
    buttons << TelegramButton.new(text: ">", data: "#animated_punk_purchase##menu:page=#{page + 1}") if next_page_entries_present

    buttons = [] if buttons.length == 1

    { caption: caption, buttons: buttons, page: page }
  end

  def animated_punk
    File.open(Rails.root.join("telegram_assets/images/black_market/punk_animate.gif"))
  end

  def selected_punk_photo(punk_number)
    Punk.find_by(number: punk_number)&.image_url
  end

  def user_punks_scope
    @user_punks_scope ||= Punk.where(owner: punk_owner_address).not_animated.order(:id)
  end

  def punk_owner_address
    @punk_owner_address ||= user.provided_wallet.length == 64 ? user.provided_wallet : TonUtils.hex_address(user.provided_wallet)
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::ANIMATED_PUNK)
  end

  def back_request_animate_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#animated_punk_purchase##request_animate:")
  end

  def back_animate_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#animated_punk_purchase##animate:")
  end

  def back_market_button(new_message: false)
    data = "#black_market##menu:"
    data += "new_message=true" if new_message

    TelegramButton.new(text: I18n.t("common.back"), data: data)
  end
end
