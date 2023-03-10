class FetchLastShardTransactions
  include RedisHelper

  CONSENSUNS_BLOCK_KEY = "consensus_block_key"

  attr_reader :toncenter_client, :last_checked_consensus_block, :last_checked_shard_block, :shard_id, :workchain

  def initialize(workchain:, shard_id: )
    @workchain = workchain
    @shard_id = shard_id.to_s
    @toncenter_client = ToncenterClient.new
    @last_checked_consensus_block = redis.get(CONSENSUNS_BLOCK_KEY)
    @last_checked_shard_block = redis.get(shard_block_key)
  end

  def call
    last_consensus_block = find_last_consensus_block
    return [] if last_checked_consensus_block == last_consensus_block

    last_shard_block = find_last_shard_block(last_consensus_block)

    range_start = last_checked_shard_block || last_shard_block
    transactions = (range_start.to_i..last_shard_block).flat_map do |block|
      t = toncenter_client.block_transactions(workchain: workchain, shard: shard_id, seqno: block)
      NewTransactionsMonitoringWorker.perform_in(60, block) if t.blank?
      t
    end

    update_last_checked_consensus_block(last_consensus_block)
    update_last_shard_block(last_shard_block)
    transactions
  end

  def reset_storage
    redis.del(shard_block_key)
    redis.del(CONSENSUNS_BLOCK_KEY)
    @last_checked_shard_block = nil
    @last_checked_consensus_block = nil
  end

  private

  def find_last_consensus_block
    toncenter_client.consensus_block
  end

  def find_last_shard_block(seqno)
    if last_checked_consensus_block && last_checked_shard_block
      seqno.to_i - last_checked_consensus_block.to_i + last_checked_shard_block.to_i
    else
      toncenter_client.shards(seqno: seqno).detect { |shard| shard['shard'] == shard_id }['seqno']
    end
  end

  def update_last_checked_consensus_block(block)
    redis.set(CONSENSUNS_BLOCK_KEY, block)
    @last_checked_consensus_block = block
  end

  def update_last_shard_block(block)
    redis.set(shard_block_key, block)
    @last_checked_shard_block = block
  end

  def shard_block_key
    @shard_key ||= "shard_block_key_#{workchain}_#{shard_id}"
  end
end
