class Telegram::Deeplink < Telegram::Base
  delegate :deeplink_arguments, to: :context
end
