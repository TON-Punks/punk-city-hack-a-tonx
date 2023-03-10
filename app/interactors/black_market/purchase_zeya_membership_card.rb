class BlackMarket::PurchaseZeyaMembershipCard < BlackMarket::BasePurchase
  MAX_PRODUCTS = 50
  MAX_PRODUCTS_PER_USER = 2

  def perform
    ApplicationRecord.transaction do
      context.fail!(error_message: I18n.t("black_market.errors.sold_out")) if sold_out?
      if max_products_bought?
        context.fail!(error_message: I18n.t("black_market.errors.max_products_reached", max_products: MAX_PRODUCTS_PER_USER))
      end

      praxis_transaction = user.praxis_transactions.create!(
        operation_type: PraxisTransaction::PRODUCT_PURCHASE,
        quantity: product.current_price
      )
      user.black_market_purchases.create!(
        black_market_product: product,
        praxis_transaction: praxis_transaction,
        data: { wallet: user.provided_wallet }
      )

      context.fail!(error_message: I18n.t("black_market.errors.not_enough_praxis")) unless user.praxis_balance_valid?

      BlackMarket::ProductPriceIncreaser.call(product)
    end
  end

  private

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::ZEYA_MEMBERSHIP_CARD)
  end

  def max_products_bought?
    user.black_market_purchases.where(black_market_product: product).size >= MAX_PRODUCTS_PER_USER
  end

  def sold_out?
    BlackMarketPurchase.where(black_market_product: product).count >= MAX_PRODUCTS
  end
end
