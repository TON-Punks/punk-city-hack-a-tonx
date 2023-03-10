# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::PremiumExchange do
  subject { described_class.call(user: user, rate: Praxis::PremiumExchange::RateFetcher::SMALL) }

  let(:user) { create(:user, prestige_level: 5, experience: experience) }
  let(:experience) { 2300 }
  let(:virtual_balance) { 1200000000 }
  let(:request) { instance_double(WithdrawRequest) }

  before do
    create(:wallet, user: user, virtual_balance: virtual_balance)
    allow(WithdrawRequest).to receive(:create).with(wallet: user.wallet, address: BlackMarket::TonPaymentProcessor::DEFAULT_TON_FEE_ADDRESS, amount: 490000000)
      .and_return(request)
    allow(Wallets::Withdraw).to receive(:call).with(withdraw_request: request)
  end

  specify do
    expect(Wallets::Withdraw).to receive(:call).with(withdraw_request: request, withdraw_info: nil)

    expect { subject }.to change { UserTransaction.count }.by(1)

    expect(user.reload.experience).to eq(1300)
    expect(user.praxis_balance).to eq(150)

    expect(described_class.call(user: user, rate: :small).error_message).to eq(I18n.t("black_market.errors.rate_limit"))
  end

  context 'when user has not enough ton for comission' do
    let(:virtual_balance) { 120000000 }

    specify do
      expect(subject.error_message).to eq(
        I18n.t("black_market.errors.low_ton_balance.text",
          ton: 0.37,
          wallet: user.wallet.pretty_address,
          wallet_balance: user.wallet.pretty_virtual_balance,
          purchase_ton_link: Telegram::Callback::Wallet::CRYPTO_BOT_LINK
        )
      )
      expect(user.praxis_balance).to eq(0)
      expect(UserTransaction.count).to eq(0)
    end
  end

  context 'when user has less experience than required' do
    let(:experience) { 100 }

    specify do
      expect(subject.error_message).to eq(I18n.t("bank.fast_exchange.errors.insufficient_experience"))
      expect(user.praxis_balance).to eq(0)
    end
  end
end
