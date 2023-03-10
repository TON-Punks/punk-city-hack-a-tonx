class BlackMarket::PurchaseEmojiPack < BlackMarket::BasePurchase
  PRAXIS_PAYMENT_METHOD = 'praxis'
  TON_PAYMENT_METHOD = 'ton'

  PAYMENT_METHODS_MAPPING = {
    PRAXIS_PAYMENT_METHOD => :praxis_payment,
    TON_PAYMENT_METHOD => :ton_payment
  }

  TON_FEE = 10

  SELLER_USER_CHAT_ID = 1351881907
  SELLER_PRAXIS_REWARD = 1000

  delegate :punk, :pay_method, to: :context

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
    add_praxis_balance_to_seller if seller_user.present?

    praxis_transaction = user.praxis_transactions.create!(
      operation_type: PraxisTransaction::PRODUCT_PURCHASE,
      quantity: product.current_price
    )

    purchase = create_black_market_purchase!(praxis_transaction)

    context.fail!(error_message: I18n.t("black_market.errors.not_enough_praxis")) unless user.praxis_balance_valid?

    BlackMarket::Purchases::Complete.call(purchase: purchase)
    BlackMarket::ProductPriceIncreaser.call(product)
  end

  def ton_payment
    result = BlackMarket::TonPaymentProcessor.call(ton_price: TON_FEE, user: user, ton_fee_address: wallet_config[:base64_address])

    context.fail!(error_message: result.error_message, error_button: result.error_button) unless result.success?

    create_black_market_purchase!
    create_user_transaction!(TON_FEE, TON_FEE / 2, 'emoji_pack')
  end

  def create_black_market_purchase!(praxis_transaction = nil)
    user.black_market_purchases.create!(
      praxis_transaction: praxis_transaction,
      black_market_product: product,
      data: { punk_number: punk.number },
      seller_user: seller_user,
      payment_method: pay_method,
      payment_amount: payment_amount
    )
  end

  def add_praxis_balance_to_seller
    seller_user.praxis_transactions.create!(
      operation_type: PraxisTransaction::PRODUCT_SOLD,
      quantity: SELLER_PRAXIS_REWARD
    )
  end

  def seller_user
    @seller_user ||= User.find_by(chat_id: SELLER_USER_CHAT_ID)
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::EMOJI_PACK)
  end

  def payment_amount
    pay_method == TON_PAYMENT_METHOD ? TON_FEE : product.current_price
  end

  def wallet_config
    @wallet_config ||= Rails.application.config_for(:contract_manager)
  end
end
