class Tournaments::DistributeHalloweenPrizes
  include Interactor
  include RedisHelper

  SEND_SCRIPT_PATH = Rails.root.join("node_scripts/tournament_distribute_halloween_prizes.js")
  delegate :address1, :address2, :address3, :address4, :address5, :dry_run, to: :context

  def call
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      SECRET_KEY="#{ContractsConfig.secret_key}"
      PUBLIC_KEY="#{ContractsConfig.public_key}"
      CONTRACT_ADDRESS="#{ContractsConfig.contracts_address['haloween_tournament']}"
      TOP1_ADDRESS="#{address1}"
      TOP2_ADDRESS="#{address2}"
      TOP3_ADDRESS="#{address3}"
      TOP4_ADDRESS="#{address4}"
      TOP5_ADDRESS="#{address5}"

      DRY_RUN="#{dry_run}"
    ENV_VARS

    `#{env_vars.squish} node #{SEND_SCRIPT_PATH}`
  end
end
