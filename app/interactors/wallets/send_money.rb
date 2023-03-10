class Wallets::SendMoney
  include Interactor
  include RedisHelper

  delegate :wallet, :amount, :address, :dry_run, to: :context

  WITHDRAW_WALLET_PATH = Rails.root.join("node_scripts/withdraw.js")

  def call
    with_lock "send-money-#{wallet.id}" do |locked|
      if locked
        return context.fail! if wallet.balance < amount || wallet.virtual_balance < amount
        everything = wallet.balance == amount
        wallet_credential = wallet.credential
        env = "PUBLIC_KEY=#{wallet_credential.public_key} SECRET_KEY=#{wallet_credential.secret_key} NANO_VALUE=#{amount} ADDRESS=#{address}"
        node_output = dry_run ? '' : `#{env} node #{WITHDRAW_WALLET_PATH}`

        error = node_output.match(/error: (.*)/)
        raise RuntimeError, node_output if error

        wallet.decrement!(:balance, amount)
        wallet.decrement!(:virtual_balance, amount)
      end
    end
  end
end
