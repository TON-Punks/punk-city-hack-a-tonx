class Praxis::FastExchange::RateCalculator
  EXPERIENCE_REQIRED = 1250

  include RedisHelper

  class << self
    def call(user_id)
      new(user_id).call
    end
  end

  def initialize(user_id)
    @user_id = user_id
  end

  def call
    Praxis::FastExchangeRate.new(exp: EXPERIENCE_REQIRED, praxis: praxis_quantity)
  end

  private

  attr_reader :user_id

  def praxis_quantity
    (EXPERIENCE_REQIRED * multiplier_manager.exchange_rate).to_i
  end

  def multiplier_manager
    @multiplier_manager ||= Praxis::FastExchange::MultiplierManager.new(user_id)
  end
end
