class BlackMarket::PurchaseWlToadz < BlackMarket::BasePurchase
  def perform
    ApplicationRecord.transaction do
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
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::WL_MUTANT_TOADZ)
  end
end
