# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchLastTransactions do
  around { |e| VCR.use_cassette('tonhub/last_transactions', &e) }

  before do
    described_class.new.send(:redis).set(described_class::CONSENSUNS_BLOCK_KEY, 20649765)
  end

  specify do
    transactions = described_class.new.call
    expect(transactions.size).to eq(2)
  end
end
