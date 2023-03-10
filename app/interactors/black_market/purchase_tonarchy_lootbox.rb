class BlackMarket::PurchaseTonarchyLootbox < BlackMarket::BasePurchase
  include RedisHelper
  delegate :pay_method, to: :context

  PRAXIS_PAYMENT_METHOD = 'praxis'
  TON_PAYMENT_METHOD = 'ton'

  PAYMENT_METHODS_MAPPING = {
    PRAXIS_PAYMENT_METHOD => :praxis_payment,
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

  def praxis_payment
    praxis_transaction = user.praxis_transactions.create!(
      operation_type: PraxisTransaction::PRODUCT_PURCHASE,
      quantity: product.current_price
    )

    if user.praxis_balance_valid?
      create_black_market_purchase!(praxis_transaction)
    else
      context.fail!(error_message: I18n.t("black_market.errors.not_enough_praxis"))
    end

    BlackMarket::ProductPriceIncreaser.call(product)
  end

  def create_black_market_purchase!(praxis_transaction = nil)
    user.black_market_purchases.create!(
      praxis_transaction: praxis_transaction,
      black_market_product: product,
      payment_method: pay_method,
      payment_amount: payment_amount
    )
  end

  def payment_amount
    pay_method == TON_PAYMENT_METHOD ? TON_FEE : product.current_price
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::TONARCHY_LOOTBOX)
  end

  def ton_payment
    result = BlackMarket::TonPaymentProcessor.call(ton_price: TON_FEE, user: user)

    if result.success?
      create_black_market_purchase!
      create_user_transaction!(TON_FEE, TON_FEE / 2, 'golden_floppy')
    else
      context.fail!(error_message: result.error_message)
    end
  end
end
