class Wallets::Withdraw
  include Interactor
  include RedisHelper

  delegate :withdraw_request, :dry_run, to: :context
  delegate :wallet, to: :withdraw_request

  WITHDRAW_WALLET_PATH = Rails.root.join("node_scripts/withdraw.js")

  def call
    with_lock "withdraw-#{wallet.id}" do |locked|
      if locked
        return context.fail! if wallet.balance < withdraw_request.amount || wallet.virtual_balance < withdraw_request.amount
        everything = wallet.balance == withdraw_request.amount
        wallet_credential = wallet.credential
        env = "PUBLIC_KEY=#{wallet_credential.public_key} SECRET_KEY=#{wallet_credential.secret_key} NANO_VALUE=#{withdraw_request.amount} ADDRESS=#{withdraw_request.address} EVERYTHING=#{everything}"
        node_output = dry_run ? '' : `#{env} node #{WITHDRAW_WALLET_PATH}`

        error = node_output.match(/error: (.*)/)
        raise RuntimeError, node_output if error

        wallet.decrement!(:balance, withdraw_request.amount)
        wallet.decrement!(:virtual_balance, withdraw_request.amount)
      end
    end
  end
end
