class BlackMarket::Purchases::ValidateUserTonPayment < BlackMarket::Purchases::BaseValidator
  delegate :purchase, to: :context

  def call
    raise InvalidStateError unless (purchase.ton_payment_method? && purchase.initiated?)

    transaction_hash = UserTonTransactionFetcher.call(
      from_address: purchase.user.wallet.base64_address_bounce,
      to_address: marketplace_address,
      ton_amount: purchase.payment_amount,
      excluded_hashes: excluded_transactions_hashes
    )

    if transaction_hash.present?
      purchase.data["user_transaction_hash"] = transaction_hash
      purchase.state = :paid
      purchase.save!

      if purchase.seller_user
        BlackMarket::ComissionPayoutWorker.perform_async(purchase.seller_user_id, seller_comission.to_f)
      end
    end
  end

  private

  def seller_comission
    if purchase.seller_comission_amount.positive?
      purchase.seller_comission_amount
    else
      (purchase.payment_amount / 2).to_f
    end
  end
end
