require 'rails_helper'

RSpec.describe BlackMarket::Purchases::ValidateUserTonPayment do
  subject { described_class.call(purchase: purchase) }

  let(:purchase) { create(:black_market_purchase, black_market_product: product, payment_method: :ton) }
  let(:product) { create(:black_market_product) }
  let(:user_wallet) { create(:wallet) }
  let(:transaction_hash) { nil }

  before do
    purchase.user.update(wallet: user_wallet)
    allow(UserTonTransactionFetcher).to receive(:call).with(
      from_address: purchase.user.wallet.base64_address_bounce,
      to_address: '',
      ton_amount: purchase.payment_amount,
      excluded_hashes: []
    ).and_return(transaction_hash)
  end

  context 'when transaction fetched' do
    let(:transaction_hash) { 'transaction_hash' }

    specify do
      subject

      expect(purchase.reload).to be_paid
      expect(purchase.data["user_transaction_hash"]).to eq(transaction_hash)
    end

    context 'when purchase has seller' do
      let(:purchase) do
        create(:black_market_purchase, black_market_product: product, seller_user: seller_user, payment_method: :ton, payment_amount: 1.0)
      end
      let(:seller_user) { create(:user) }

      specify do
        expect(BlackMarket::ComissionPayoutWorker).to receive(:perform_async).with(seller_user.id, 0.5)

        subject

        expect(purchase.reload).to be_paid
        expect(purchase.data["user_transaction_hash"]).to eq(transaction_hash)
      end
    end
  end

  context 'when transaction missing' do
    let(:transaction_hash) { nil }

    specify do
      subject

      expect(purchase.reload).to be_initiated
    end
  end

  context 'when praxis purchase' do
    let(:purchase) { create(:black_market_purchase, black_market_product: product, payment_method: :praxis) }

    specify do
      expect { subject }.to raise_error(BlackMarket::Purchases::BaseValidator::InvalidStateError)
    end
  end

  context 'when already paid purchase' do
    let(:purchase) { create(:black_market_purchase, black_market_product: product, state: :paid) }

    specify do
      expect { subject }.to raise_error(BlackMarket::Purchases::BaseValidator::InvalidStateError)
    end
  end
end
