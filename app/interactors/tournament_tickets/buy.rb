class TournamentTickets::Buy
  include Interactor

  TOURNAMENT_DISTRIBUTER_ADDRESS = 'EQD3G-VALnbPNSojVAx5Kov3Q7HzNqLrcxmrlF-b7DgNfcV-'

  delegate :user, :count, to: :context
  delegate :wallet, to: :user

  TICKETS_TO_PRICE = {
    3 => 1_000_000_000,
    9 => 2_500_000_000,
    15 => 3_500_000_000
  }

  def call
    price = TICKETS_TO_PRICE[count]
    return unless price

    if price > wallet.virtual_balance
      context.fail!(error_message: I18n.t("black_market.errors.rate_limit")) if processing_frozen?
      context.fail!(error_message: I18n.t("tournament.errors.low_ton_balance", balance: wallet.virtual_balance, address: wallet.pretty_address))
    end

    count.times { TournamentTicket.create(user: user) }
    Wallets::SendMoney.call(amount: TICKETS_TO_PRICE[count], wallet: user.wallet, address: TOURNAMENT_DISTRIBUTER_ADDRESS)
    freeze_processing
  end

  private

  def processing_frozen?
    redis.exists?(redis_freeze_processing_key)
  end

  def freeze_processing
    redis.setex(redis_freeze_processing_key, 30, "1")
  end

  def redis_freeze_processing_key
    "ton-payment-processing-#{user.id}"
  end

end
