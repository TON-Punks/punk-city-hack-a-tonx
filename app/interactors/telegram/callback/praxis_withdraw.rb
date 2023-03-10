class Telegram::Callback::PraxisWithdraw < Telegram::Callback
  include RedisHelper

  delegate :wallet, to: :user

  def menu
    user.update!(next_step: nil) if user.next_step

    buttons = [
      [TelegramButton.new(text: I18n.t("bank.withdraw.menu.button"), data: "#praxis_withdraw##request_sum:")],
      [bank_menu_button]
    ]

    text = I18n.t("bank.withdraw.menu.caption",
                  comission_praxis: (Praxis::Withdraw::PRAXIS_COMISSION_FEE * 100).to_i,
                  comission_ton: Praxis::Withdraw::TON_FEE,
                  praxis_balance: user.praxis_balance,
                  wallet_balance: user.wallet.pretty_virtual_balance,
                  praxis_min: Praxis::Withdraw::MIN,
                  praxis_max: Praxis::Withdraw::MAX
                )

    if message_to_update?
      update_inline_keyboard(photo: bank_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: bank_photo, text: text, buttons: buttons)
    end
  end

  def request_sum
    buttons = [[back_button]]

    text = I18n.t("bank.withdraw.request_sum.caption",
                  praxis_min: Praxis::Withdraw::MIN,
                  praxis_max: Praxis::Withdraw::MAX
                )

    user.update!(next_step: "#praxis_withdraw##request_address:")

    if message_to_update?
      update_inline_keyboard(photo: bank_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: bank_photo, text: text, buttons: buttons)
    end
  end

  def request_address
    praxis_amount = telegram_request.message.text.strip.to_i

    if praxis_amount < Praxis::Withdraw::MIN || praxis_amount > Praxis::Withdraw::MAX
      return(
        show_error(
          I18n.t("bank.withdraw.errors.invalid_praxis_amount",
                 praxis: praxis_amount,
                 praxis_min: Praxis::Withdraw::MIN,
                 praxis_max: Praxis::Withdraw::MAX
               )
        )
      )
    end

    praxis_amount_with_fee = (praxis_amount * (1 + Praxis::Withdraw::PRAXIS_COMISSION_FEE)).to_i

    if praxis_amount_with_fee > user.praxis_balance
      return(
        show_error(
          I18n.t("bank.withdraw.errors.insufficient_praxis_balance", praxis: praxis_amount_with_fee - user.praxis_balance)
        )
      )
    end

    buttons = [[back_button]]

    text = I18n.t("bank.withdraw.request_address.caption",
                  praxis_balance: user.praxis_balance,
                  wallet_balance: user.wallet.pretty_virtual_balance,
                  praxis_amount: praxis_amount,
                  total_praxis_amount: (praxis_amount * (1 + Praxis::Withdraw::PRAXIS_COMISSION_FEE)).to_i,
                  ton_fee: Praxis::Withdraw::TON_FEE
                )

    user.update!(next_step: "#praxis_withdraw##perform:praxis=#{praxis_amount}")

    if message_to_update?
      update_inline_keyboard(photo: bank_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: bank_photo, text: text, buttons: buttons)
    end
  end

  def perform
    receiving_address = telegram_request.message.text.strip.to_s
    praxis_amount = callback_arguments["praxis"].to_s

    result = Praxis::Withdraw.call(user: user, receiving_address: receiving_address, praxis_amount: praxis_amount)

    return(show_error(result.error_message)) unless result.success?

    buttons = [[back_button]]
    text = I18n.t("bank.withdraw.perform.caption")

    user.reload.update!(next_step: nil)

    if message_to_update?
      update_inline_keyboard(photo: bank_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: bank_photo, text: text, buttons: buttons)
    end
  end

  def show_error(text)
    user.reload.update!(next_step: nil)
    buttons = [[back_button]]

    if message_to_update?
      update_inline_keyboard(photo: bank_photo, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: bank_photo, text: text, buttons: buttons)
    end
  end

  private

  def bank_photo
    File.open(TelegramImage.path("bank.png"))
  end

  def bank_menu_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#bank##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#praxis_withdraw##menu:")
  end
end
