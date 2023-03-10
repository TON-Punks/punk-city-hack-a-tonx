# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lootboxes::CheckResult do
  let!(:lootbox) { create :lootbox, :with_black_market_purchase, id: 77, series: :initial }
  let(:user) { lootbox.user }

  specify do
    VCR.use_cassette("toncenter/lootboxes_contract") do
      described_class.call
    end

    expect(lootbox.reload.address).to be_present
  end
end
