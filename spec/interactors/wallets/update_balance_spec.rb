# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wallets::UpdateBalance do
  let(:address) { "EQDpUkyAa6lZ12P3ZB2PL_rmWwI1I55BU4kxw_rssFL5dswA" }
  let(:wallet) { create :wallet, base64_address_bounce: address }

  around { |e| VCR.use_cassette("tonhub/account", &e) }

  before { stub_telegram }

  specify do
    expect do
      described_class.call(wallet: wallet)
    end.to change { wallet.reload.pretty_balance }.from("0.0").to("16.990742563")
  end

  context "when has not finished games" do
    before do
      create :rock_paper_scissors_game, opponent: wallet.user, state: :started, bet: 1_500_000_000, bet_currency: :ton
      create :rock_paper_scissors_game, creator: wallet.user, state: :created, bet: 2_540_000_000, bet_currency: :ton
    end

    specify do
      described_class.call(wallet: wallet)

      expect(wallet.reload.pretty_virtual_balance).to eq("12.950742563")
    end
  end
end
