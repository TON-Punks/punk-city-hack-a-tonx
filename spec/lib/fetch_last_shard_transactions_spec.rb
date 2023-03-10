# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchLastShardTransactions do
  let(:workchain) { 0 }
  let(:shard_id) { '-9223372036854775808' }

  before { described_class.new(workchain: 0, shard_id: shard_id).reset_storage }

  context 'first call' do
    around { |e| VCR.use_cassette("toncenter/FetchLastShardTransactions/first_call", &e) }

    it 'fetches last transactions' do
      service = described_class.new(workchain: 0, shard_id: shard_id)
      transactions = service.call
      expect(transactions.size).to eq(1)

    end
  end

  context 'consequent call' do
    it do
      expect(NewTransactionsMonitoringWorker).to receive(:perform_in).with(60, 25613201)
      service = described_class.new(workchain: 0, shard_id: shard_id)

      VCR.use_cassette("toncenter/FetchLastShardTransactions/first_call") do
        service.call
      end

      transactions = VCR.use_cassette("toncenter/FetchLastShardTransactions/consequent_call") do
        service.call
      end

      expect(transactions.size).to eq(4)
    end
  end
end
