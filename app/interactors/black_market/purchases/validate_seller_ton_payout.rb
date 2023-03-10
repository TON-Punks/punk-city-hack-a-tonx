class BlackMarket::Purchases::ValidateSellerTonPayout < BlackMarket::Purchases::BaseValidator
  delegate :purchase, :seller_fee, to: :context

  def call
    raise InvalidStateError unless (purchase.ton_payment_method? && purchase.paid?)

    transaction_hash = UserTonTransactionFetcher.call(
      from_address: marketplace_address,
      to_address: purchase.seller_user.wallet.base64_address_bounce,
      ton_amount: purchase.payment_amount / 2,
      excluded_hashes: excluded_transactions_hashes
    )

    if transaction_hash.present?
      purchase.data["seller_transaction_hash"] = transaction_hash
      purchase.state = :seller_paid
      purchase.save!
    end
  end
end
