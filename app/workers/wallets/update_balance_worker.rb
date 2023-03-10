class Wallets::UpdateBalanceWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(wallet_id)
    wallet = Wallet.find(wallet_id)
    wallet.user.with_locale { Wallets::UpdateBalance.call(wallet: wallet) }
  end
end
