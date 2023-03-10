# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackMarket::ProductPriceDecreaseWorker do
  subject(:perform) { described_class.new.perform }

  let!(:first_product) { create(:black_market_product, slug: 'first') }
  let!(:second_product) { create(:black_market_product, slug: 'second') }

  specify do
    expect(BlackMarket::ProductPriceDecreaser).to receive(:call).with(first_product)
    expect(BlackMarket::ProductPriceDecreaser).to receive(:call).with(second_product)

    perform
  end
end
