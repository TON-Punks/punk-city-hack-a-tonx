class Wallets::LootboxWithdraw
  include Interactor
  include RedisHelper

  delegate :withdraw_request, :withdraw_info, :dry_run, to: :context
  delegate :wallet, to: :withdraw_request

  SCRIPT_PATH = Rails.root.join("node_scripts/lootbox_purchase.js")

  def call
    with_lock "withdraw-#{wallet.id}" do |locked|
      if locked
        return context.fail! if wallet.balance < withdraw_request.amount || wallet.virtual_balance < withdraw_request.amount
        everything = wallet.balance == withdraw_request.amount
        wallet_credential = wallet.credential

        env = <<~ENV
          CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
          PUBLIC_KEY=#{wallet_credential.public_key}
          SECRET_KEY=#{wallet_credential.secret_key}
          NANO_VALUE=#{withdraw_request.amount}
          ADDRESS="#{ContractsConfig.contracts_address[withdraw_info[:lootbox].lite_series? ? 'lootboxes_lite' : 'lootboxes']}"
          EVERYTHING=#{everything}
          LOOTBOX_ID=#{withdraw_info[:lootbox].id}
        ENV
        node_output = dry_run ? '' : `#{env.squish} node #{SCRIPT_PATH}`

        error = node_output.match(/error: (.*)/)
        raise RuntimeError, node_output if error

        wallet.decrement!(:balance, withdraw_request.amount)
        wallet.decrement!(:virtual_balance, withdraw_request.amount)
      end
    end
  end
end
