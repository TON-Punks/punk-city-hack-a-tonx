class Punks::ValidateConnection
  include Interactor

  delegate :punk, to: :context

  def call
    user = punk.user
    return if user.blank?

    client = ToncenterClient.new
    transactions = client.account_transactions(address: user.wallet.address)
    addresses = transactions.to_a.map { |t| t['in_msg']['source'] }.select(&:present?).uniq

    transaction_from_owner = addresses.
      map { |base64_address| TonUtils.hex_address(base64_address) }.
      include?(punk.owner)

    return if transaction_from_owner

    PunkConnections::Disconnect.call(punk_connection: punk.connected_punk_connection)
    Telegram::Notifications::PunkNewOwner.call(user: user, punk: punk)
  end
end
