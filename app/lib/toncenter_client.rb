class ToncenterClient
  attr_reader :client

  def initialize
    @client = HTTP.headers("X-API-Key" => ToncenterConfig.api_key, "accept" => "application/json")
  end

  def account(address:)
    result(client.get(url('getAddressInformation'), params: { address: address }))
  end

  def account_transactions(address:)
    result(client.get(url('getTransactions'), params: { address: address }))
  end

  def consensus_block
    result(client.get(url('getConsensusBlock')))['consensus_block']
  end

  def shards(seqno:)
    result(client.get(url('shards'), params: { seqno: seqno }))['shards']
  end

  def block_transactions(workchain:, shard:, seqno:)
    response = client.get(url('getBlockTransactions'), params: { workchain: workchain, shard: shard, seqno: seqno })
    result(response)['transactions']
  rescue
    raise "#{response.parse('application/json')}"
  end

  private

  def url(path)
    "#{ToncenterConfig.url}#{path}"
  end

  def result(response)
    response.parse('application/json')['result']
  end
end
