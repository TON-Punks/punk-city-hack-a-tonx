class BlackMarket::RevokeSbtItem
  include Interactor
  include RedisHelper

  REVOKE_SCRIPT_PATH = Rails.root.join("node_scripts/revoke_sbt_item.js")

  delegate :address, to: :context

  def call
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      MANAGER_SECRET_KEY="#{ContractsConfig.manager_secret_key}"
      MANAGER_PUBLIC_KEY="#{ContractsConfig.manager_public_key}"
      CONTRACT_ADDRESS="#{address}"
    ENV_VARS

    `#{env_vars.squish} node #{REVOKE_SCRIPT_PATH}`
  end
end
