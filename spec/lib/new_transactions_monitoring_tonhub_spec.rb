# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewTransactionsMonitoringTonhub do
  let!(:address) { 'EQAcNCCM7-d1fy7nrXKEEyyF8Pt4mExLCRvAgU6v7z1NGldL' }
  let!(:wallet) { create :wallet, base64_address_bounce: address }
  let!(:tournament) { create :tournament, address: address }

  around { |e| VCR.use_cassette('tonhub/last_transactions', &e) }

  before do
    FetchLastTransactions.new.reset_storage
  end

  specify do
    expect(Wallets::DeployWorker).to receive(:perform_async)

    described_class.call
  end
end
