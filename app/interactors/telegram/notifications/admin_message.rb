class Telegram::Notifications::AdminMessage < Telegram::Base
  delegate :message, to: :context

  def call
    send_message(message)
  end
end
