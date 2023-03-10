class Telegram::Callback::Bank < Telegram::Callback
  include RedisHelper

  MENU_KEYS = %i[regular_exchange premium_exchange ton_exchange]

  delegate :wallet, to: :user

  def menu
    buttons = [
      [TelegramButton.new(text: I18n.t("bank.menu.buttons.withdraw"), data: "#praxis_withdraw##menu:")]
    ]

    buttons += MENU_KEYS.map do |menu_key|
      [TelegramButton.new(text: I18n.t("bank.menu.buttons.#{menu_key}"), data: "#bank###{menu_key}:")]
    end

    buttons << [back_button]

    text = I18n.t("bank.menu.caption", praxis: user.praxis_balance, exp: user.effective_experience)

    if message_to_update?
      update_inline_keyboard(photo: bank_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: bank_photo, text: text, buttons: buttons)
    end
  end

  def fast_exchange
    buttons = if fast_exchange_rate.praxis.positive?
                [
                  [fast_exchange_button("button")],
                  [bank_menu_button]
                ]
              else
                [[bank_menu_button]]
              end

    text = I18n.t("bank.fast_exchange.caption",
      exp_rate: fast_exchange_rate.exp,
      praxis_rate: fast_exchange_rate.praxis,
      exp: user.effective_experience,
      praxis: user.praxis_balance,
      rates_updates_info: I18n.t("bank.fast_exchange.rates_updates.#{user_has_default_fast_rates? ? 'no_exchanges' : 'has_exchanges'}")
    )

    if message_to_update?
      update_inline_keyboard(photo: fast_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: fast_exchange_photo, text: text, buttons: buttons)
    end
  end

  def regular_exchange
    buttons = [
      [TelegramButton.new(text: I18n.t("bank.regular_exchange.button"), data: "#bank##perform_regular_exchange:")],
      [bank_menu_button]
    ]

    ongoing_exchange_caption = regular_time_calculator.humanized_ongoing_interval.present? ? I18n.t("bank.regular_exchange.ongoing_exchange_caption", time_until_finish: regular_time_calculator.humanized_ongoing_interval) : ''

    text = I18n.t("bank.regular_exchange.caption",
      conversion_time: regular_time_calculator.humanized_interval,
      time_until_reset: regular_time_calculator.humanized_until_reset,
      exp: user.effective_experience,
      default_time: (Praxis::RegularExchange::TimeCalculator::DEFAULT_TIME / 60).to_i,
      ongoing_exchange: ongoing_exchange_caption,
      praxis: user.praxis_balance
    )

    if message_to_update?
      update_inline_keyboard(photo: regular_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: regular_exchange_photo, text: text, buttons: buttons)
    end
  end

  def premium_exchange
    buttons = Praxis::PremiumExchange::RateFetcher::RATES.map do |rate_name, rate|
      [TelegramButton.new(text: I18n.t("bank.premium_exchange.button", exp: rate.exp, praxis: rate.praxis, ton: rate.ton_fee), data: "#bank##perform_premium_exchange:rate_name=#{rate_name}")]
    end

    buttons << [bank_menu_button]

    text = I18n.t("bank.premium_exchange.caption",
      exp: user.effective_experience,
      praxis: user.praxis_balance
    )

    if message_to_update?
      update_inline_keyboard(photo: premium_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: premium_exchange_photo, text: text, buttons: buttons)
    end
  end

  def ton_exchange
    buttons = ton_exchange_rates.map do |rate_name, rate|
      [TelegramButton.new(text: I18n.t("bank.ton_exchange.button", praxis: rate.praxis), data: "#bank##request_ton_exchange:rate=#{rate_name}")]
    end

    buttons << [bank_menu_button]

    exchange_rate_text = ton_exchange_rates.map do |rate_name, rate|
      I18n.t("bank.ton_exchange.exchange_rate", praxis: rate.praxis, ton: rate.ton.to_i)
    end.join("\n")

    text = I18n.t("bank.ton_exchange.caption", balance_ton: wallet.pretty_balance, exchange_rate: exchange_rate_text)

    if message_to_update?
      update_inline_keyboard(photo: ton_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: ton_exchange_photo, text: text, buttons: buttons)
    end
  end

  def perform_fast_exchange
    buttons = [
      [bank_menu_button]
    ]

    received_praxis = fast_exchange_rate.praxis

    result = Praxis::FastExchange.call(user: user)

    text = if result.success?
             I18n.t("bank.fast_exchange.result", received_praxis: received_praxis)
           else
             result.error_message
           end

    buttons.prepend([fast_exchange_button("repeat_button")]) if result.success?

    if message_to_update?
      update_inline_keyboard(photo: fast_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: fast_exchange_photo, text: text, buttons: buttons)
    end
  end

  def perform_regular_exchange
    buttons = [[bank_menu_button]]

    result = Praxis::RegularExchange.call(user: user)

    text = if result.success?
             I18n.t("bank.regular_exchange.result", interval: regular_time_calculator.humanized_interval)
           else
             result.error_message
           end

    if message_to_update?
      update_inline_keyboard(photo: regular_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: regular_exchange_photo, text: text, buttons: buttons)
    end
  end

  def perform_premium_exchange
    buttons = [[bank_menu_button]]

    result = Praxis::PremiumExchange.call(user: user, rate: callback_arguments["rate_name"])

    text = if result.success?
             I18n.t("bank.premium_exchange.result", praxis: result.praxis_received)
           else
             result.error_message
           end

    if message_to_update?
      update_inline_keyboard(photo: premium_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: premium_exchange_photo, text: text, buttons: buttons)
    end
  end

  def request_ton_exchange
    rate = callback_arguments["rate"].to_s

    buttons = [
      TelegramButton.new(text: I18n.t("bank.ton_exchange.confirmation.confirm"), data: "#bank##perform_ton_exchange:rate=#{rate}"),
      TelegramButton.new(text: I18n.t("bank.ton_exchange.confirmation.cancel"), data: "#bank##ton_exchange:")
    ]

    fetched_rate = ton_exchange_rates.fetch(rate.to_sym)

    text = I18n.t("bank.ton_exchange.confirmation.caption", praxis: fetched_rate.praxis, ton: fetched_rate.ton.to_i)

    if message_to_update?
      update_inline_keyboard(photo: ton_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: ton_exchange_photo, text: text, buttons: buttons)
    end

  end

  def perform_ton_exchange
    buttons = [[bank_menu_button]]

    result = Praxis::TonExchange.call(user: user, rate: callback_arguments["rate"].to_s)

    text = if result.success?
             I18n.t("bank.ton_exchange.result", praxis: result.praxis_received)
           else
             result.error_message
           end

    if message_to_update?
      update_inline_keyboard(photo: ton_exchange_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: ton_exchange_photo, text: text, buttons: buttons)
    end

  end

  private

  def bank_photo
    File.open(TelegramImage.path("bank.png"))
  end

  def fast_exchange_photo
    File.open(TelegramImage.path("fast_exchange.png"))
  end

  def regular_exchange_photo
    File.open(TelegramImage.path("regular_exchange.png"))
  end

  def premium_exchange_photo
    File.open(TelegramImage.path("premium_exchange.png"))
  end

  def ton_exchange_photo
    File.open(TelegramImage.path("ton_praxis_exchange.png"))
  end

  def user_has_default_fast_rates?
    Praxis::FastExchange::MultiplierManager::DEFAULT_MIN_MULTIPLIER == Praxis::FastExchange::MultiplierManager.new(user.id).current_multiplier
  end

  def ton_exchange_rates
    @ton_exchange_rates ||= Praxis::TonExchange::RateFetcher::RATES
  end

  def fast_exchange_rate
    @fast_exchange_rate ||= actual_fast_exchange_rate
  end

  def actual_fast_exchange_rate
    Praxis::FastExchange::RateCalculator.call(user.id)
  end

  def regular_time_calculator
    @regular_time_calculator ||= Praxis::RegularExchange::TimeCalculator.call(user)
  end

  def fast_exchange_button(button_title_key)
    TelegramButton.new(
      text: I18n.t("bank.fast_exchange.#{button_title_key}",
        exp_rate: actual_fast_exchange_rate.exp,
        praxis_rate: actual_fast_exchange_rate.praxis
      ),
      data: "#bank##perform_fast_exchange:"
    )
  end

  def bank_menu_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#bank##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#wallet##menu:")
  end
end
