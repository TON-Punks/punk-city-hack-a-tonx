class Wallets::DeployWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(wallet_id)
    wallet = Wallet.find(wallet_id)
    Wallets::DeployWallet.call(wallet: wallet)
  end
end
