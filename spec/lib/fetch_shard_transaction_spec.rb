# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchShardTransaction do
  around { |e| VCR.use_cassette("toncenter/fetch_transaction", &e) }

  specify do
    transactions = described_class.new(seqno: 20644653, shard_id: '-9223372036854775808', workchain: 0).call
    expect(transactions.size).to eq(0)
  end
end
