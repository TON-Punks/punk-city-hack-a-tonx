class FetchShardTransaction
  include RedisHelper

  CONSENSUNS_BLOCK_KEY = "consensus_block_key"

  attr_reader :toncenter_client,  :shard_id, :workchain, :seqno

  def initialize(workchain:, shard_id:, seqno:)
    @workchain = workchain
    @shard_id = shard_id.to_s
    @toncenter_client = ToncenterClient.new
    @seqno = seqno.to_s
  end

  def call
    toncenter_client.block_transactions(workchain: workchain, shard: shard_id, seqno: seqno)
  end
end
