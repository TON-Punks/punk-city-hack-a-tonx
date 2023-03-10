class BlackMarket::BurnSbtItem
  include Interactor
  include RedisHelper

  BURN_SCRIPT_PATH = Rails.root.join("node_scripts/burn_sbt_item.js")

  delegate :wallet, :address, to: :context

  def call
    wallet_credential = wallet.credential
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      SECRET_KEY="#{wallet_credential.secret_key}"
      PUBLIC_KEY="#{wallet_credential.public_key}"
      CONTRACT_ADDRESS="#{address}"
    ENV_VARS

    `#{env_vars.squish} node #{BURN_SCRIPT_PATH}`
  end
end
