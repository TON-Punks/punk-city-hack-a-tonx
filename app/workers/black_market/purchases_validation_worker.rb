class BlackMarket::PurchasesValidationWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    ton_purchases.paid.where(seller_user_id: nil).each do |purchase|
      BlackMarket::Purchases::Complete.call(purchase: purchase)
    end

    ton_purchases.seller_paid.each do |purchase|
      BlackMarket::Purchases::Complete.call(purchase: purchase)
    end

    ton_purchases.paid.where.not(seller_user_id: nil).each do |purchase|
      BlackMarket::Purchases::ValidateSellerTonPayout.call(purchase: purchase)
    end

    ton_purchases.initiated.each do |purchase|
      BlackMarket::Purchases::ValidateUserTonPayment.call(purchase: purchase)
    end

    ton_purchases.initiated.where("updated_at < ?", 1.hour.ago).map { |purchase| purchase.update(state: :failed) }
    ton_purchases.paid.where.not(seller_user_id: nil).where("updated_at < ?", 1.hour.ago).map do |purchase|
      purchase.update(state: :failed)
    end
  end

  private

  def ton_purchases
    BlackMarketPurchase.ton_payment_method
  end
end
