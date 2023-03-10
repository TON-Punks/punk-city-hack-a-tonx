class TonhubClient
  attr_reader :client

  def initialize
    @client = HTTP.headers("accept" => "application/json")
  end

  def latest_block
    result(client.get(url('block/latest')))['last']
  end

  def block_transactions(seqno:)
    response = client.get(url("block/#{seqno}"))
    result(response)['block']['shards']
  # rescue
  #   raise "#{response.parse('application/json')}"
  end

  def account(address:, seqno: nil)
    seqno ||= latest_block['seqno']

    result(client.get(url("block/#{seqno}/#{address}")))['account']
  end

  private

  def url(path)
    "https://mainnet-v4.tonhubapi.com/#{path}"
  end

  def result(response)
    response.parse('application/json')
  end
end
