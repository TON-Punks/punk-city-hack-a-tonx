class BlackMarket::PurchaseGoldenFloppy < BlackMarket::BasePurchase
  include RedisHelper

  COLLECTION_ADDRESS = 'EQBK0C55ZuZ8spx4CJkE367LJEKmk3WS8Rrkvl-xXpmEhFGO'
  PRAXIS_PAYMENT_METHOD = 'praxis'
  TON_PAYMENT_METHOD = 'ton'

  PAYMENT_METHODS_MAPPING = {
    PRAXIS_PAYMENT_METHOD => :praxis_payment,
    TON_PAYMENT_METHOD => :ton_payment
  }

  TON_FEE = 1_000

  delegate :user, :pay_method, to: :context

  def perform
    ApplicationRecord.transaction do
      payment_result = begin
        send(PAYMENT_METHODS_MAPPING.fetch(pay_method))
      rescue KeyError
        context.fail!(error_message: I18n.t("common.error"))
      end

      return context.fail!(error_message: I18n.t("common.error")) if get_index >= 9

      BlackMarket::DeploySbtItem.call(collection_address: COLLECTION_ADDRESS, item_index: get_index, content_number: get_index + 1, owner_address: user.provided_wallet)
      increment_index
      Telegram::Notifications::NewGoldenFloppy.call(user: user)
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

  def ton_payment
    result = BlackMarket::TonPaymentProcessor.call(ton_price: TON_FEE, user: user, ton_fee_address: wallet_config[:base64_address])

    context.fail!(error_message: result.error_message, error_button: result.error_button) unless result.success?

    create_black_market_purchase!
    create_user_transaction!(TON_FEE, TON_FEE, 'golden_floppy')
  end

  def create_black_market_purchase!(praxis_transaction = nil)
    user.black_market_purchases.create!(
      praxis_transaction: praxis_transaction,
      black_market_product: product,
      payment_method: pay_method,
      payment_amount: payment_amount
    )
  end

  def get_index
    redis.get(golden_floppy_key).to_i
  end

  def increment_index
    redis.incr(golden_floppy_key)
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::GOLDERN_FLOPPY)
  end

  def payment_amount
    pay_method == TON_PAYMENT_METHOD ? TON_FEE : product.current_price
  end

  def wallet_config
    @wallet_config ||= Rails.application.config_for(:contract_manager)
  end

  def golden_floppy_key
    "golden-floppy-count"
  end
end
