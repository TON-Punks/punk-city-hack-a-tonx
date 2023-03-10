class BlackMarket::PurchaseInitialLootbox < BlackMarket::BasePurchase
  include RedisHelper
  delegate :pay_method, to: :context

  TON_PAYMENT_METHOD = 'ton'
  PAYMENT_METHODS_MAPPING = {
    TON_PAYMENT_METHOD => :ton_payment
  }

  TON_FEE = 5

  def perform
    ApplicationRecord.transaction do
      payment_result = begin
        send(PAYMENT_METHODS_MAPPING.fetch(pay_method))
      rescue KeyError
        context.fail!(error_message: I18n.t("common.error"))
      end
    end
  end

  private

  def create_black_market_purchase!
    user.black_market_purchases.create!(
      black_market_product: product,
      payment_method: pay_method,
      payment_amount: payment_amount
    )
  end

  def payment_amount
    pay_method == TON_PAYMENT_METHOD ? TON_FEE : product.current_price
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::PUNK_LOOTBOX_INITIAL)
  end

  def ton_payment
    lootbox = Lootbox.create!(series: :initial)
    result = BlackMarket::TonPaymentProcessor.call(
      ton_price: TON_FEE,
      user: user,
      withdraw_class: Wallets::LootboxWithdraw,
      withdraw_info: { lootbox: lootbox }
    )

    if result.success?
      black_market_purchase = create_black_market_purchase!
      lootbox.update!(black_market_purchase: black_market_purchase, prepaid: true)
      create_user_transaction!(TON_FEE, TON_FEE, 'initial_lootbox')
    else
      context.fail!(error_message: result.error_message)
    end
  end
end
