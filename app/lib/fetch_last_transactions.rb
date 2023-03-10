class FetchLastTransactions
  include RedisHelper

  CONSENSUNS_BLOCK_KEY = "tonhub_latest_block_key".freeze
  CACHE_TTL = 6.hours.to_i.freeze

  attr_reader :client, :last_checked_block, :last_checked_shard_block, :workchain

  def initialize
    @client = TonhubClient.new
    @last_checked_block = redis.get(CONSENSUNS_BLOCK_KEY)
  end

  def call
    last_block = find_last_block
    return [] if last_checked_block && last_checked_block == last_block

    range_start = last_checked_block || last_block
    transactions = (range_start.to_i..last_block).flat_map do |block|
      client.block_transactions(seqno: block)
            .select { |shard| shard["workchain"] != -1 }
            .map { |shard| shard["transactions"] }
    end.flatten

    update_last_checked_block(last_block)
    transactions
  end

  def reset_storage
    redis.del(CONSENSUNS_BLOCK_KEY)
    @last_checked_block = nil
  end

  private

  def find_last_block
    client.latest_block["seqno"]
  end

  def update_last_checked_block(block)
    redis.setex(CONSENSUNS_BLOCK_KEY, CACHE_TTL, block)
    @last_checked_block = block
  end
end
