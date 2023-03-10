class RockPaperScissorsGames::SendMove
  include Interactor
  include RedisHelper

  SEND_SCRIPT_PATH = Rails.root.join("node_scripts/send_moves.js")
  USER_TYPES = %w[opponent creator]
  delegate :game, :user_type, :dry_run, to: :context

  def call
    return if game.address.blank?

    raise ArgumentError if !USER_TYPES.include?(user_type)
    user = game.public_send(user_type)
    return if user.blank?

    damages = game.game_rounds.order(:id).pluck(:creator_damage, :opponent_damage).flatten.map(&:to_i).join(',')
    game_rounds = game.game_rounds.order(:id)
    wallet_credential = user.wallet.credential
    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      SECRET_KEY="#{wallet_credential.secret_key}"
      PUBLIC_KEY="#{wallet_credential.public_key}"
      CONTRACT_ADDRESS="#{game.address}"
      BET_VALUE="#{game.bet}"
      GAME_ROUNDS=#{game.game_rounds.size}
      GAME_MOVES="#{game_rounds.map(&user_type.to_sym).map(&:to_i).join}"
      DAMAGES="#{damages}"
      DRY_RUN="#{dry_run}"
    ENV_VARS

    `#{env_vars.squish} node #{SEND_SCRIPT_PATH}`
  end
end
