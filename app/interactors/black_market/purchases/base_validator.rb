class BlackMarket::Purchases::BaseValidator
  include Interactor
  include TonHelper

  InvalidStateError = Class.new(StandardError)

  def call
    raise NotImplementedError
  end

  private

  def excluded_transactions_hashes
    @excluded_transactions_hashes ||= BlackMarketPurchase.ton_payment_method.map do |purchase|
      [purchase.data["user_transaction_hash"], purchase.data["seller_transaction_hash"]]
    end.flatten.compact
  end

  def marketplace_address
    @marketplace_address ||= wallet_config[:base64_address]
  end

  def wallet_config
    @wallet_config ||= Rails.application.config_for(:contract_manager)
  end
end
