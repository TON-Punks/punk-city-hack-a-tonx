# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlackMarket::PurchaseGoldenFloppy do
  subject { described_class.call(user: user, pay_method: pay_method) }

  let(:provided_wallet) { "test" }
  let(:user) { create(:user, provided_wallet: provided_wallet) }
  let(:praxis_balance) { 60_000 }

  let(:product) { create(:black_market_product, current_price: product_price) }
  let(:product_price) { 60_000 }

  let(:payment_amount) { product_price }

  before do
    allow(BlackMarketProduct).to receive(:find_by).with(slug: BlackMarketProduct::GOLDERN_FLOPPY).and_return(product)
    user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: praxis_balance)
  end

  before do
    expect(BlackMarket::DeploySbtItem).to receive(:call)
    expect(TelegramApi).to receive(:send_message).twice
  end

  context "when pay method is praxis" do
    let(:pay_method) { "praxis" }

    specify do
      expect(BlackMarket::ProductPriceIncreaser).to receive(:call).with(product)

      expect { subject }.to_not change(UserTransaction, :count)

      expect(user.praxis_balance).to eq(0)
      purchase = user.black_market_purchases.first
      expect(purchase.black_market_product).to eq(product)
    end
  end

  context "when pay method is ton" do
    let(:pay_method) { "ton" }

    let(:product_price) { 1_000_000_000_000 }
    let(:request) { instance_double(WithdrawRequest) }

    let(:payment_amount) { described_class::TON_FEE }

    before do
      create(:wallet, user: user, virtual_balance: product_price)
      allow(WithdrawRequest).to receive(:create).with(wallet: user.wallet,
        address: BlackMarket::TonPaymentProcessor::DEFAULT_TON_FEE_ADDRESS, amount: product_price)
                                                .and_return(request)
      allow(Wallets::Withdraw).to receive(:call).with(withdraw_request: request)
    end

    specify do
      expect(Wallets::Withdraw).to receive(:call).with(withdraw_request: request, withdraw_info: nil)

      expect { subject }.to change { UserTransaction.count }.by(1)

      expect(user.praxis_balance).to eq(praxis_balance)
      purchase = user.black_market_purchases.first
      expect(purchase.black_market_product).to eq(product)
    end
  end
end
