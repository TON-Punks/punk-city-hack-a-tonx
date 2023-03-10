require "rails_helper"

RSpec.describe BlackMarket::ProductPriceDecreaser do
  describe "#call" do
    subject { described_class.new(product).call }

    let(:product) { create(:black_market_product, min_price: 500, current_price: current_price) }
    let(:current_price) { 600 }

    specify do
      expect { subject }.to change(product, :current_price).from(current_price).to(564)
    end

    context "when decreased price lower than minimal price" do
      let(:current_price) { 501 }

      specify do
        expect { subject }.to change(product, :current_price).from(current_price).to(500)
      end
    end
  end
end
