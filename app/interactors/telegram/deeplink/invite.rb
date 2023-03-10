class Telegram::Deeplink::Invite < Telegram::Deeplink
  def call
    return if user.onboarded?

    Deeplinks::Invite.consume(deeplink_arguments.merge(referred_id: user.id))
  end
end
