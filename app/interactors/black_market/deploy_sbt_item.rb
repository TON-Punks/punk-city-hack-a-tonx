class BlackMarket::DeploySbtItem
  include Interactor
  include RedisHelper

  DEPLOY_SCRIPT_PATH = Rails.root.join("node_scripts/deploy_sbt_item.js")

  delegate :item_index, :content_number, :owner_address, :collection_address, to: :context

  COLLECTION_TO_CONTENT = {
    'EQBK0C55ZuZ8spx4CJkE367LJEKmk3WS8Rrkvl-xXpmEhFGO' => 'ipfs://bafybeigzmuzzuknexkohmsoxxjdhwuhbidne6xqnstbdgidvsc5no4oesq/floppy-disk'
  }

  def call
    content = COLLECTION_TO_CONTENT[collection_address]
    raise ArgumentError if content.blank? || content_number.blank?

    env_vars = <<~ENV_VARS
      CLIENT_ENDPOINT="#{ToncenterConfig.json_rpc_url}"
      MANAGER_SECRET_KEY="#{ContractsConfig.manager_secret_key}"
      MANAGER_PUBLIC_KEY="#{ContractsConfig.manager_public_key}"
      OWNER_ADDRESS="#{owner_address}"
      EDITOR_ADDRESS="#{ContractsConfig.manager_address}"
      CONTENT="#{content}#{content_number}.json"
      COLLECTION_ADDRESS="#{collection_address}"
      ITEM_INDEX=#{item_index}
    ENV_VARS

    `#{env_vars.squish} node #{DEPLOY_SCRIPT_PATH}`
  end
end
