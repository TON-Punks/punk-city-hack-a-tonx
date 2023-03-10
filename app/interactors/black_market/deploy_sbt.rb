class BlackMarket::DeploySbt
  include Interactor
  include RedisHelper

  DEPLOY_SCRIPT_PATH = Rails.root.join("node_scripts/deploy_sbt.js")

  delegate :number, :owner_address, :dry_run, to: :context

  def call
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      MANAGER_SECRET_KEY="#{ContractsConfig.manager_secret_key}"
      MANAGER_PUBLIC_KEY="#{ContractsConfig.manager_public_key}"
      EDITOR_ADDRESS="#{ContractsConfig.manager_address}"
      OWNER_ADDRESS="#{owner_address}"
      CONTENT="https://punk-metaverse.fra1.digitaloceanspaces.com/floppy-disk-metadata/floppy-disk#{number}.json"
    ENV_VARS

    node_output = `#{env_vars.squish} node #{DEPLOY_SCRIPT_PATH}`
    context.base64_address = node_output.match(/base64_address: (.*)/)[1]
  end
end
