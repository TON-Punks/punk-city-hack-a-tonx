require 'rails_helper'

RSpec.describe BlackMarket::PurchaseNeuropunk do
  subject { described_class.call(user: user, punk: punk, pay_method: pay_method) }

  let(:user) { create(:user) }
  let(:praxis_balance) { 200 }
  let(:punk) { create(:punk) }

  let(:product) { create(:black_market_product, current_price: product_price) }
  let(:product_price) { 150 }
  let!(:seller) { create(:user, chat_id: 5265424415) }

  let(:payment_amount) { product_price }

  before do
    allow(BlackMarketProduct).to receive(:find_by).with(slug: BlackMarketProduct::NEUROPUNK).and_return(product)
    user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: praxis_balance)
  end

  context 'when pay method is unknown' do
    let(:pay_method) { 'abcde' }
    let(:product_price) { 201 }

    specify do
      expect(BlackMarket::ProductPriceIncreaser).not_to receive(:call).with(product)

      expect(subject.error_message).to eq(I18n.t("common.error"))

      expect(user.praxis_balance).to eq(praxis_balance)
      expect(user.reload.black_market_purchases).to be_blank
    end
  end

  context 'when pay method is praxis' do
    let(:pay_method) { 'praxis' }

    specify do
      expect(BlackMarket::ProductPriceIncreaser).to receive(:call).with(product)

      expect { subject }.to_not change { UserTransaction.count }

      expect(user.praxis_balance).to eq(50)
      expect(seller.praxis_balance).to eq(75)
      purchase = user.black_market_purchases.first
      expect(purchase.black_market_product).to eq(product)
      expect(purchase.data["punk_number"]).to eq(punk.number)
      expect(purchase).to be_completed
    end

    context 'when user has not enough praxis' do
      let(:product_price) { 201 }

      specify do
        expect(BlackMarket::ProductPriceIncreaser).not_to receive(:call).with(product)

        expect(subject.error_message).to eq(I18n.t("black_market.errors.not_enough_praxis"))

        expect(user.praxis_balance).to eq(praxis_balance)
        expect(user.reload.black_market_purchases).to be_blank
      end
    end
  end

  context 'when pay method is ton' do
    let(:pay_method) { 'ton' }

    let(:virtual_balance) { 100000000000 }
    let(:request) { instance_double(WithdrawRequest) }

    let(:payment_amount) { described_class::TON_FEE }

    before do
      create(:wallet, user: user, virtual_balance: virtual_balance)
      allow(WithdrawRequest).to receive(:create).with(wallet: user.wallet, address: BlackMarket::TonPaymentProcessor::DEFAULT_TON_FEE_ADDRESS, amount: 10000000000)
        .and_return(request)
      allow(Wallets::Withdraw).to receive(:call).with(withdraw_request: request)
    end

    specify do
      expect(Wallets::Withdraw).to receive(:call).with(withdraw_request: request, withdraw_info: nil)

      expect { subject }.to change { UserTransaction.count }.by(1)

      expect(user.praxis_balance).to eq(200)
      expect(seller.praxis_balance).to eq(0)
      purchase = user.black_market_purchases.first
      expect(purchase.black_market_product).to eq(product)
      expect(purchase.data["punk_number"]).to eq(punk.number)
      expect(purchase).to be_initiated
    end

    context 'when user has not enough ton' do
      let(:virtual_balance) { 12000 }

      specify do
        expect(subject.error_message).to eq(
          I18n.t("black_market.errors.low_ton_balance.text",
            ton: 9.999988,
            wallet: user.wallet.pretty_address,
            wallet_balance: user.wallet.pretty_virtual_balance,
            purchase_ton_link: Telegram::Callback::Wallet::CRYPTO_BOT_LINK
          )
        )

        expect(UserTransaction.count).to eq(0)
        expect(user.praxis_balance).to eq(200)
        expect(user.reload.black_market_purchases).to be_blank
      end
    end
  end
end
