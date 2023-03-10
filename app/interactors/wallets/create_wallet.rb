class Wallets::CreateWallet
  include Interactor

  delegate :user, to: :context

  def call
    result = Wallets::CreateCredentials.call

    wallet = Wallet.create(
      user: user,
      address: result.address,
      base64_address: result.base64_address,
      base64_address_bounce: result.base64_address_bounce
    )

    WalletCredential.create(
      wallet: wallet,
      public_key: result.public_key,
      secret_key: result.secret_key,
      mnemonic: result.mnemonic
      )
  end
end
