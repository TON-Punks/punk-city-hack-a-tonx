class BlackMarket::ComissionPayoutProcessor
  include Interactor
  include TonHelper
  include RedisHelper

  PROCESSING_DELAY = 2.minutes.to_i

  WITHDRAW_WALLET_PATH = Rails.root.join("node_scripts/withdraw.js")

  delegate :user, :ton_fee, to: :context

  def call
    return reschedule_job if processing_frozen?
    freeze_processing

    env = "PUBLIC_KEY=#{wallet_public_key} SECRET_KEY=#{wallet_secret_key} NANO_VALUE=#{ton_fee_nano} ADDRESS=#{wallet_address} EVERYTHING=false"
    node_output = `#{env} node #{WITHDRAW_WALLET_PATH}`

    error = node_output.match(/error: (.*)/)
    raise RuntimeError, node_output if error
  end

  private

  def wallet_public_key
    wallet_config.fetch(:public_key)
  end

  def wallet_secret_key
    wallet_config.fetch(:secret_key)
  end

  def ton_fee_nano
    @ton_fee_nano ||= to_nano(ton_fee)
  end

  def wallet_address
    user.wallet.pretty_address
  end

  def reschedule_job
    BlackMarket::ComissionPayoutWorker.perform_in(PROCESSING_DELAY, user.id, ton_fee)
  end

  def processing_frozen?
    redis.exists?(redis_freeze_processing_key)
  end

  def freeze_processing
    redis.setex(redis_freeze_processing_key, 100, "1")
  end

  def redis_freeze_processing_key
    "black-market-comission-withdraw"
  end

  def wallet_config
    @wallet_config ||= Rails.application.config_for(:contract_manager)
  end
end
