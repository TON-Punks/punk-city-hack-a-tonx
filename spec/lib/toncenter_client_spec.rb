# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToncenterClient do
  subject (:client) { described_class.new }
  describe 'account' do
    let(:address) { '0:eec8e3c0f8b8c87164b9dd2397913716be6f57f84c1255a0db0ff053218a8830' }

    around { |e| VCR.use_cassette("toncenter/account/#{address}", &e) }

    it { expect(client.account(address: address)['balance']).to eq('7162565697490') }
  end

  describe 'account_transactions' do
    let(:address) { 'EQA3b4Rb2mN9HDI4RlcUx4FS8MOOSNuCo-mg9T9QrDoV-uMZ' }

    around { |e| VCR.use_cassette("toncenter/account_transactions/#{address}", &e) }

    specify do
      transactions = client.account_transactions(address: address)
      addresses = transactions.map { |t| t['in_msg']['source'] }.select(&:present?).uniq
      expect(addresses.size).to eq(7)
    end
  end

  describe 'consensus_block' do
    around { |e| VCR.use_cassette("toncenter/consensus_block", &e) }

    its(:consensus_block) { is_expected.to eq(20435145) }
  end

  describe 'shards' do
    around { |e| VCR.use_cassette("toncenter/shards", &e) }

    it { expect(client.shards(seqno: 20435145).first['seqno']).to eq(25613124) }
  end

  describe 'block_transactions' do
    around { |e| VCR.use_cassette("toncenter/block_transactions", &e) }

    specify do
      transactions = client.block_transactions(workchain: 0, shard: -9223372036854775808, seqno: 24907408)
      expect(transactions.size).to eq(2)
    end
  end
end
