# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlackMarket::TonPaymentProcessor do
  subject { described_class.call(user: user, ton_price: ton_price) }

  let(:user) { create(:user) }
  let(:virtual_balance) { to_nano(1.22) }
  let(:withdraw_request) { instance_double(WithdrawRequest) }
  let(:ton_fee_address) { BlackMarket::TonPaymentProcessor::DEFAULT_TON_FEE_ADDRESS }
  let(:ton_price) { 1.21 }

  def to_nano(num)
    (num * 1_000_000_000).to_i
  end

  before do
    create(:wallet, user: user, virtual_balance: virtual_balance)
    allow(WithdrawRequest).to receive(:create).with(wallet: user.wallet, address: ton_fee_address, amount: to_nano(ton_price))
      .and_return(withdraw_request)
    allow(Wallets::Withdraw).to receive(:call).with(withdraw_request: withdraw_request, withdraw_info: nil)
  end

  context "when user has enough ton" do
    specify do
      expect(subject).to be_success
      expect(subject.withdraw_request).to eq(withdraw_request)
    end

    context "when ton fee address provided" do
      subject { described_class.call(user: user, ton_price: ton_price, ton_fee_address: overriden_ton_fee_address) }

      let(:overriden_ton_fee_address) { 'overriden_ton_fee_address' }
      let(:ton_fee_address) { overriden_ton_fee_address }

      specify do
        expect(subject).to be_success
        expect(subject.withdraw_request).to eq(withdraw_request)
      end
    end

    context "when rate limit has triggered" do
      specify do
        expect(subject).to be_success
        expect(subject.withdraw_request).to eq(withdraw_request)

        error_result = described_class.call(user: user, ton_price: ton_price)
        expect(error_result).not_to be_success
        expect(error_result.error_message).to eq(I18n.t("black_market.errors.rate_limit"))
      end
    end
  end

  context "when user has not enough ton" do
    let(:virtual_balance) { to_nano(1.209) }

    specify do
      expect(subject).not_to be_success
      expect(subject.error_message).to eq(
        I18n.t("black_market.errors.low_ton_balance.text",
          ton: 0.001,
          wallet: user.wallet.pretty_address,
          wallet_balance: user.wallet.pretty_virtual_balance,
          purchase_ton_link: Telegram::Callback::Wallet::CRYPTO_BOT_LINK
        )
      )
    end
  end
end
