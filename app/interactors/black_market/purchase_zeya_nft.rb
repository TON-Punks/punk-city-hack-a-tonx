class BlackMarket::PurchaseZeyaNft < BlackMarket::BasePurchase
  TON_FEE = 49

  def perform
    ApplicationRecord.transaction do
      request = make_ton_payment
      user.black_market_purchases.create!(black_market_product: product, data: { withdraw_request_id: request.id })

      BlackMarket::ProductPriceIncreaser.call(product)
    end
  end

  private

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::ZEYA_NFT)
  end

  def make_ton_payment
    result = BlackMarket::TonPaymentProcessor.call(ton_price: TON_FEE, user: user)

    result.success? ? result.withdraw_request : context.fail!(error_message: result.error_message)
  end
end
