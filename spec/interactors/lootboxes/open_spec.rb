# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lootboxes::Open do
  let(:result) { Lootboxes::SERIES_TO_CONTENT[:initial].first }
  let!(:lootbox) { create :lootbox, :with_black_market_purchase, series: :initial, result: result }

  specify do
    expect(Telegram::Notifications::OpenLootbox).to receive(:call)

    described_class.call(lootbox: lootbox)

    expect(lootbox.user.weapons.count).to eq(1)
  end
end
