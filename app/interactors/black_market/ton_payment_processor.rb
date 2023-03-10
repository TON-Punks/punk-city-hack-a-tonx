class BlackMarket::TonPaymentProcessor
  include Interactor
  include TonHelper
  include RedisHelper

  DEFAULT_TON_FEE_ADDRESS = "EQDpUkyAa6lZ12P3ZB2PL_rmWwI1I55BU4kxw_rssFL5dswA"

  delegate :user, :ton_price, :withdraw_class, :withdraw_info, to: :context

  def call
    validate_rate_limit!
    validate_user_ton_balance!

    klass = withdraw_class || Wallets::Withdraw

    context.withdraw_request = WithdrawRequest.create(wallet: user.wallet, address: ton_fee_address, amount: ton_price_nano).tap do |withdraw_request|
      klass.call(withdraw_request: withdraw_request, withdraw_info: withdraw_info)
      freeze_processing
    end
  end

  private

  def validate_rate_limit!
    context.fail!(error_message: I18n.t("black_market.errors.rate_limit")) if processing_frozen?
  end

  def validate_user_ton_balance!
    if ton_price_nano > user.wallet.virtual_balance
      context.fail!(error_message: low_ton_balance_error, error_button: :continue)
    end
  end

  def low_ton_balance_error
    I18n.t("black_market.errors.low_ton_balance.text",
      ton: from_nano(ton_price_nano - user.wallet.virtual_balance),
      wallet: user.wallet.pretty_address,
      wallet_balance: user.wallet.pretty_virtual_balance,
      purchase_ton_link: Telegram::Callback::Wallet::CRYPTO_BOT_LINK
    )
  end

  def processing_frozen?
    redis.exists?(redis_freeze_processing_key)
  end

  def freeze_processing
    redis.setex(redis_freeze_processing_key, 60, "1")
  end

  def redis_freeze_processing_key
    "ton-payment-processing-#{user.id}"
  end

  def ton_price_nano
    @ton_price_nano ||= to_nano(ton_price)
  end

  def ton_fee_address
    @ton_fee_address ||= context.ton_fee_address.presence || DEFAULT_TON_FEE_ADDRESS
  end
end
