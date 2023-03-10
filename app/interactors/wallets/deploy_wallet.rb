class Wallets::DeployWallet
  include Interactor

  CREATE_WALLET_PATH = Rails.root.join("node_scripts/create_wallet.js")

  delegate :wallet, to: :context

  def call
    wallet_credential = wallet.credential
    node_output = `PUBLIC_KEY=#{wallet_credential.public_key} SECRET_KEY=#{wallet_credential.secret_key} node #{CREATE_WALLET_PATH}`

    error = node_output.match(/error: (.*)/)
    raise RuntimeError, node_output if error
    wallet.active!
  end
end
