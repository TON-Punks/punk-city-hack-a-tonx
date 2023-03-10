# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TonhubClient do
  describe 'latest_block' do
    around { |e| VCR.use_cassette('tonhub/latest_block', &e) }

    specify do
      result = described_class.new.latest_block
      expect(result['seqno']).to be_present
    end
  end

  describe 'block_transactions' do
    around { |e| VCR.use_cassette('tonhub/block_transactions', &e) }

    specify do
      result = described_class.new.block_transactions(seqno: 20647919)
      expect(result.size).to eq(2)
      expect(result[1]['workchain']).to eq(0)
    end
  end

  describe 'account'  do
    around { |e| VCR.use_cassette('tonhub/account', &e) }

    specify do
      result = described_class.new.account(address: "EQDpUkyAa6lZ12P3ZB2PL_rmWwI1I55BU4kxw_rssFL5dswA")

      expect(result['balance']['coins']).to eq('16990742563')
    end
  end
end
