class Praxis::BaseExchange
  include Interactor
  include RedisHelper

  delegate :user, to: :context

  def call
    with_lock "praxis-exchange-#{user.id}" do |locked|
      if locked
        perform
      end
    end
  end
end
