class Users::CheckTonConnection
  include Interactor

  NODE_SCRIPT_PATH = Rails.root.join("node_scripts/decode_ton_connect_data.cjs")

  delegate :user, :retries, to: :context

  def call
    punk_connection = user.punk_connections.requested.first
    return if punk_connection.blank? || user.punk.present?

    events = ton_connect.bridge_events.split("\n")
    return Users::CheckTonConnectionWorker.perform_in(5, user.id, retries + 1) if events.empty?
    event = parse_events(events)

    return if event['event'] != 'connect'
    return if punk_connection.punk.owner != event['payload']['items'].first['address']

    PunkConnections::Connect.call(punk_connection: punk_connection)
    user.reload
    Telegram::Notifications::PunkConnected.call(user: user)
  end

  def parse_events(events)
    message_data = JSON.parse(events.last.gsub("data: ", ""))
    JSON.parse(`PUBLIC_KEY=#{ton_connect.public_key} SECRET_KEY=#{ton_connect.secret_key} FROM=#{message_data['from']} MESSAGE=#{message_data['message']} node #{NODE_SCRIPT_PATH}`)
  end

  def ton_connect
    @ton_connect ||= TonConnect.new(user)
  end
end
