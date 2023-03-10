require 'rails_helper'

RSpec.describe BlackMarket::ProductPriceIncreaser do
  describe '#call' do
    subject { described_class.new(product).call }

    let(:product) { create(:black_market_product, current_price: current_price) }
    let(:current_price) { 1000 }

    specify do
      expect { subject }.to change(product, :current_price).from(current_price).to(current_price + 30)
    end

    context 'when calculated increase is greater than 50' do
      let(:current_price) { 10000 }

      specify do
        expect { subject }.to change(product, :current_price).from(current_price).to(current_price + 50)
      end
    end

    context 'when calculated increase is lower than 10' do
      let(:current_price) { 100 }

      specify do
        expect { subject }.to change(product, :current_price).from(current_price).to(current_price + 10)
      end
    end
  end
end
