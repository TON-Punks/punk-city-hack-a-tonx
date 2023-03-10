require 'rails_helper'

RSpec.describe BlackMarket::PurchasesValidationWorker do
  subject(:perform) { described_class.new.perform }

  let(:product) { create(:black_market_product) }
  let(:paid_without_seller_purchase) do
    create(:black_market_purchase, payment_method: :ton, state: :paid, seller_user_id: nil, black_market_product: product)
  end
  let(:seller_paid_with_seller_purchase) do
    create(:black_market_purchase, payment_method: :ton, state: :seller_paid, seller_user_id: 10, black_market_product: product)
  end
  let(:paid_with_seller_purchase) do
    create(:black_market_purchase, payment_method: :ton, state: :paid, seller_user_id: 10, black_market_product: product)
  end
  let(:initiated_purchase) do
    create(:black_market_purchase, payment_method: :ton, state: :initiated, black_market_product: product)
  end
  let!(:old_initiated_purchase) do
    create(:black_market_purchase, payment_method: :ton, state: :initiated, updated_at: 2.hours.ago, black_market_product: product)
  end
  let!(:old_paid_purchase_with_seller) do
    create(:black_market_purchase, payment_method: :ton, state: :initiated, seller_user_id: 11, updated_at: 2.hours.ago, black_market_product: product)
  end

  before do
    allow(BlackMarket::Purchases::ValidateUserTonPayment).to receive(:call).with(purchase: old_initiated_purchase)
    allow(BlackMarket::Purchases::ValidateUserTonPayment).to receive(:call).with(purchase: old_paid_purchase_with_seller)
  end

  specify do
    expect(BlackMarket::Purchases::Complete).to receive(:call).with(purchase: paid_without_seller_purchase)
    expect(BlackMarket::Purchases::Complete).to receive(:call).with(purchase: seller_paid_with_seller_purchase)
    expect(BlackMarket::Purchases::ValidateSellerTonPayout).to receive(:call).with(purchase: paid_with_seller_purchase)
    expect(BlackMarket::Purchases::ValidateUserTonPayment).to receive(:call).with(purchase: initiated_purchase)

    perform

    expect(old_initiated_purchase.reload).to be_failed
    expect(old_paid_purchase_with_seller.reload).to be_failed
  end
end
