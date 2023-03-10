class BlackMarket::Purchases::Callbacks::Base
  include Interactor

  delegate :purchase, to: :context

  def call
    raise NotImplementedError
  end
end
