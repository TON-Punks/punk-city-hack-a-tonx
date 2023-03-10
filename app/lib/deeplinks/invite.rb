class Deeplinks::Invite
  def self.encode(user_id)
    Base64.urlsafe_encode64({ type: 'invite', user_id: user_id }.to_json)
  end

  def self.consume(options)
    user = User.find(options[:user_id])
    referred = User.find(options[:referred_id])

    Referral.create(user: user, referred: referred) rescue nil
  end
end
