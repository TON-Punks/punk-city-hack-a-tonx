class Lootboxes::ProcessPrepaid
  include Interactor

  delegate :lootbox, to: :context

  TON_FEE = 0.01

  def call
    result = BlackMarket::TonPaymentProcessor.call(
      ton_price: TON_FEE,
      user: lootbox.user,
      withdraw_class: Wallets::LootboxWithdraw,
      withdraw_info: { lootbox: lootbox }
    )

    if result.success?
      lootbox.update(prepaid: true)
    else
      context.fail!(error_message: result.error_message)
    end
  end
end
