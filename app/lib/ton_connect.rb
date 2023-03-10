class TonConnect
  extend RedisHelper

  BRIDGE_URL = 'https://bridge.tonapi.io/bridge/events'
  REDIS_KEY = "tonconnect"
  TTL = 1.day.to_i
  NODE_SCRIPT_PATH = Rails.root.join("node_scripts/ton_connect_data.cjs")

  attr_reader :user, :data

  def initialize(user)
    @user = user
    @data = itialize_data
  end

  def url
    @url ||= data[:url]
  end

  def public_key
    @public_key ||= data[:public_key]
  end

  def secret_key
    @secret_key ||= data[:secret_key]
  end

  def client_id
    @client_id ||= url.match(/id=(.*)&r/)[1]
  end

  def bridge_events
    payload = ''
    HTTParty.get(BRIDGE_URL, query: { client_id: client_id }, stream_body: true) do |fragment|
      break if fragment.start_with?("body: heartbeat")

      payload << fragment
    end

    payload
  end

  private

  def itialize_data
    return redis_data if redis_data.present?

    node_output = `node #{NODE_SCRIPT_PATH}`
    url = node_output.match(/url: (.*)\s/)[1]
    public_key = node_output.match(/publicKey: (.*)\s/)[1]
    secret_key = node_output.match(/secretKey: (.*)\s/)[1]

    { url: url, public_key: public_key, secret_key: secret_key }.tap do |d|
      self.redis_data = d.to_json
    end
  end

  def redis_data
    @redis_data ||= JSON.parse(self.class.redis.get("#{REDIS_KEY}-#{user.id}") || '{}').symbolize_keys
  end

  def redis_data=(json)
    self.class.redis.setex("#{REDIS_KEY}-#{user.id}", TTL, json)
  end
end
