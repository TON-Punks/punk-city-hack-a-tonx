# This class should be used to redeploy tournament contracts

class Tournaments::Deploy
  include Interactor
  include RedisHelper

  DEPLOY_SCRIPT_PATH = Rails.root.join("node_scripts/deploy_tournament_from_wallet.js")

  delegate :dry_run, to: :context

  def call
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      MANAGER_SECRET_KEY="#{ContractsConfig.manager_secret_key}"
      MANAGER_PUBLIC_KEY="#{ContractsConfig.manager_public_key}"
      MANAGER_ADDRESS="#{ContractsConfig.manager_address}"
      DRY_RUN="#{dry_run}"
    ENV_VARS

    node_output = `#{env_vars.squish} node #{DEPLOY_SCRIPT_PATH}`
    context.address = node_output.match(/base64_address: (.*)/)[1]
  end
end
