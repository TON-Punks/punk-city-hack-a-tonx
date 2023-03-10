# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tournaments::UpdateBalance do
  let(:address) { 'EQDpUkyAa6lZ12P3ZB2PL_rmWwI1I55BU4kxw_rssFL5dswA' }
  let(:tournament) { create :tournament, address: address }

  around { |e| VCR.use_cassette("tonhub/account", &e) }

  before { stub_telegram }

  specify do
    expect {
      described_class.call(tournament: tournament)
    }.to change { tournament.reload.pretty_balance }.from('0.0').to('16.990742563')
  end
end
