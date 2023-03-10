class BlackMarket::DeployNftCollection
  include Interactor
  include RedisHelper

  DEPLOY_SCRIPT_PATH = Rails.root.join("node_scripts/deploy_nft_collection.js")

  delegate :content_json, to: :context

  def call
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      MANAGER_SECRET_KEY="#{ContractsConfig.manager_secret_key}"
      MANAGER_PUBLIC_KEY="#{ContractsConfig.manager_public_key}"
      OWNER_ADDRESS="#{ContractsConfig.manager_address}"
      CONTENT="#{content_json}"
    ENV_VARS

    node_output = `#{env_vars.squish} node #{DEPLOY_SCRIPT_PATH}`
    context.base64_address = node_output.match(/base64_address: (.*)/)[1]
  end
end
