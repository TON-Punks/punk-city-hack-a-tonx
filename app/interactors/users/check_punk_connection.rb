class Users::CheckPunkConnection
  include Interactor

  BLANK_TRANSACTIONS_ERROR = Class.new(StandardError)

  delegate :user, to: :context

  def call
    punk_connection = user.punk_connections.requested.first
    return if punk_connection.blank? || user.punk.present?

    client = ToncenterClient.new
    transactions = client.account_transactions(address: user.wallet.address)
    raise BLANK_TRANSACTIONS_ERROR if transactions.nil?

    addresses = transactions.to_a.map { |t| t["in_msg"]["source"] }.select(&:present?).uniq

    transaction_from_owner = addresses
                             .map { |base64_address| TonUtils.hex_address(base64_address) }
                             .include?(punk_connection.punk.owner)
    return unless transaction_from_owner

    user.reload
    PunkConnections::Connect.call(punk_connection: punk_connection)
    Telegram::Notifications::PunkConnected.call(user: user)
  end
end
