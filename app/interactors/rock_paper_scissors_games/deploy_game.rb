class RockPaperScissorsGames::DeployGame
  include Interactor
  include RedisHelper

  DEPLOY_SCRIPT_PATH = Rails.root.join("node_scripts/deploy_from_wallet.js")

  delegate :game, :dry_run, to: :context

  def call
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      MANAGER_SECRET_KEY="#{ContractsConfig.manager_secret_key}"
      MANAGER_PUBLIC_KEY="#{ContractsConfig.manager_public_key}"
      MANAGER_ADDRESS="#{ContractsConfig.manager_address}"
      CREATOR_ADDRESS="#{game.creator.wallet.address}"
      OPPONENT_ADDRESS="#{game.opponent.wallet.address}"
      CREATOR_HEALTH="#{game.creator_health}"
      OPPONENT_HEALTH="#{game.opponent_health}"
      GAME_ID="#{game.id}"
      DRY_RUN="#{dry_run}"
    ENV_VARS

    node_output = `#{env_vars.squish} node #{DEPLOY_SCRIPT_PATH}`
    base64_address = node_output.match(/base64_address: (.*)/)[1]

    game.update!(address: base64_address)
  end
end
