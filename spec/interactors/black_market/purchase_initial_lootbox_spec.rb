# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackMarket::PurchaseInitialLootbox do
  let(:pay_method) { "ton" }
  let(:user) { create(:user) }
  let(:product) { create(:black_market_product) }
  let(:product_price) { 100_000_000 }
  let(:payment_amount) { described_class::TON_FEE }

  before do
    create(:wallet, user: user, virtual_balance: product_price)

    allow(BlackMarketProduct).to receive(:find_by).with(slug: BlackMarketProduct::PUNK_LOOTBOX_INITIAL).and_return(product)
    allow(BlackMarket::TonPaymentProcessor).to receive(:call).and_return(double(success?: true))
  end

  specify do
    described_class.call(user: user, pay_method: pay_method)

    purchase = user.black_market_purchases.first
    expect(purchase.black_market_product).to eq(product)
    expect(user.lootboxes.created.count).to eq(1)
  end
end
