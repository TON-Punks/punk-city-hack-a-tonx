require 'rails_helper'

RSpec.describe BlackMarket::Purchases::ValidateSellerTonPayout do
  subject { described_class.call(purchase: purchase) }

  let(:purchase) do
    create(:black_market_purchase, black_market_product: product, seller_user: seller_user, payment_method: :ton, state: :paid, payment_amount: 1.0)
  end
  let(:product) { create(:black_market_product) }
  let(:seller_user) { create(:user) }
  let(:seller_wallet) { create(:wallet) }
  let(:transaction_hash) { nil }

  before do
    purchase.seller_user.update(wallet: seller_wallet)
    allow(UserTonTransactionFetcher).to receive(:call).with(
      from_address: '',
      to_address: purchase.seller_user.wallet.base64_address_bounce,
      ton_amount: purchase.payment_amount / 2,
      excluded_hashes: []
    ).and_return(transaction_hash)
  end

  context 'when transaction fetched' do
    let(:transaction_hash) { 'transaction_hash' }

    specify do
      subject

      expect(purchase.reload).to be_seller_paid
      expect(purchase.data["seller_transaction_hash"]).to eq(transaction_hash)
    end
  end

  context 'when transaction missing' do
    let(:transaction_hash) { nil }

    specify do
      subject

      expect(purchase.reload).to be_paid
    end
  end

  context 'when praxis purchase' do
    let(:purchase) do
      create(:black_market_purchase, black_market_product: product, seller_user: seller_user, payment_method: :praxis)
    end

    specify do
      expect { subject }.to raise_error(BlackMarket::Purchases::BaseValidator::InvalidStateError)
    end
  end

  context 'when already seller paid purchase' do
    let(:purchase) do
      create(:black_market_purchase, black_market_product: product, seller_user: seller_user, state: :seller_paid)
    end

    specify do
      expect { subject }.to raise_error(BlackMarket::Purchases::BaseValidator::InvalidStateError)
    end
  end
end
