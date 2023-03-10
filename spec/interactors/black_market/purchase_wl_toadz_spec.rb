# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackMarket::PurchaseWlToadz do
  subject { described_class.call(user: user) }

  let(:user) { create(:user, provided_wallet: provided_wallet) }
  let(:provided_wallet) { 'ABCD' }
  let(:praxis_balance) { 200 }

  let(:product) { create(:black_market_product, current_price: product_price) }
  let(:product_price) { 150 }

  before do
    user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: praxis_balance)
    allow(BlackMarketProduct).to receive(:find_by).with(slug: BlackMarketProduct::WL_MUTANT_TOADZ).and_return(product)
  end

  specify do
    expect(BlackMarket::ProductPriceIncreaser).to receive(:call).with(product)

    subject

    expect(user.praxis_balance).to eq(50)
    purchase = user.black_market_purchases.first
    expect(purchase.black_market_product).to eq(product)
    expect(purchase.data["wallet"]).to eq(provided_wallet)
  end

  context 'when user has not enough praxis' do
    let(:product_price) { 201 }

    specify do
      expect(subject.error_message).to eq(I18n.t("black_market.errors.not_enough_praxis"))

      expect(user.praxis_balance).to eq(praxis_balance)
      expect(user.reload.black_market_purchases).to be_blank

      expect(BlackMarket::ProductPriceIncreaser).not_to receive(:call).with(product)
    end
  end
end
