class MigrateWalletCredentials < ActiveRecord::Migration[6.1]
  def change
    Wallet.find_each do |wallet|
      WalletCredential.create!(
        wallet: wallet,
        secret_key: wallet.secret_key,
        public_key: wallet.public_key,
        mnemonic: wallet.mnemonic
      )
    end
  end
end
