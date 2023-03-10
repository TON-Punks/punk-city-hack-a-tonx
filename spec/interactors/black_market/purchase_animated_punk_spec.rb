# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackMarket::PurchaseAnimatedPunk do
  subject { described_class.call(user: user, punk: punk, pay_method: pay_method) }

  let(:user) { create(:user) }
  let(:praxis_balance) { 200 }
  let(:punk) { create(:punk) }

  let(:product) { create(:black_market_product, current_price: product_price) }
  let(:product_price) { 150 }

  around { |e| VCR.use_cassette("animated_punks/400", &e) }

  let(:aws_client) { instance_double(Aws::S3::Client) }
  let(:s3_resource) { instance_double(Aws::S3::Resource) }
  let(:s3_bucket) { instance_double(Aws::S3::Bucket) }
  let(:s3_object) { instance_double(Aws::S3::Object) }
  let(:key) { "animated_punks_video/#{punk.number}.mp4" }

  before do
    allow(Aws::S3::Client).to receive(:new).with(
      access_key_id: AwsConfig.access_key_id,
      secret_access_key: AwsConfig.secret_access_key,
      endpoint: AwsConfig.endpoint,
      region: AwsConfig.region
    ).and_return(aws_client)
    allow(Aws::S3::Resource).to receive(:new).with(client: aws_client).and_return(s3_resource)
    allow(s3_resource).to receive(:bucket).with('punk-metaverse').and_return(s3_bucket)
    allow(s3_bucket).to receive(:object).with(key).and_return(s3_object)
    allow(s3_object).to receive(:exists?).and_return(false)
    allow(BlackMarketProduct).to receive(:find_by).with(slug: BlackMarketProduct::ANIMATED_PUNK).and_return(product)
  end

  context 'when pay method is unknown' do
    let(:pay_method) { 'abcde' }
    let(:product_price) { 201 }

    before do
      user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: praxis_balance)
    end

    specify do
      expect(subject.error_message).to eq(I18n.t("common.error"))

      expect(user.praxis_balance).to eq(praxis_balance)
      expect(user.reload.black_market_purchases).to be_blank
      expect(punk.reload.animated_at).to be_blank

      expect(BlackMarket::ProductPriceIncreaser).not_to receive(:call).with(product)
    end
  end

  context 'when pay method is praxis' do
    let(:pay_method) { 'praxis' }

    before do
      user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: praxis_balance)
    end

    specify do
      expect(BlackMarket::ProductPriceIncreaser).to receive(:call).with(product)

      subject

      expect(user.praxis_balance).to eq(50)
      purchase = user.black_market_purchases.first
      expect(purchase.black_market_product).to eq(product)
      expect(purchase.data["punk_number"]).to eq(punk.number)
      expect(punk.reload.animated_at).to be_present
    end

    context 'when user has not enough praxis' do
      let(:product_price) { 201 }

      specify do
        expect(subject.error_message).to eq(I18n.t("black_market.errors.not_enough_praxis"))

        expect(user.praxis_balance).to eq(praxis_balance)
        expect(user.reload.black_market_purchases).to be_blank
        expect(punk.reload.animated_at).to be_blank

        expect(BlackMarket::ProductPriceIncreaser).not_to receive(:call).with(product)
      end
    end
  end

  context 'when pay method is ton' do
    let(:pay_method) { 'ton' }

    let(:virtual_balance) { 100000000000 }
    let(:request) { instance_double(WithdrawRequest) }

    before do
      create(:wallet, user: user, virtual_balance: virtual_balance)
      allow(WithdrawRequest).to receive(:create).with(wallet: user.wallet, address: BlackMarket::TonPaymentProcessor::DEFAULT_TON_FEE_ADDRESS, amount: 30000000000)
        .and_return(request)
      allow(Wallets::Withdraw).to receive(:call).with(withdraw_request: request)
    end

    specify do
      expect(Wallets::Withdraw).to receive(:call).with(withdraw_request: request, withdraw_info: nil)

      subject

      expect(user.praxis_balance).to eq(0)
      purchase = user.black_market_purchases.first
      expect(purchase.black_market_product).to eq(product)
      expect(purchase.data["punk_number"]).to eq(punk.number)
      expect(punk.reload.animated_at).to be_present
    end

    context 'when user has not enough ton' do
      let(:virtual_balance) { 12000 }

      specify do
        expect(subject.error_message).to eq(
          I18n.t("black_market.errors.low_ton_balance.text",
            ton: 29.999988,
            wallet: user.wallet.pretty_address,
            wallet_balance: user.wallet.pretty_virtual_balance,
            purchase_ton_link: Telegram::Callback::Wallet::CRYPTO_BOT_LINK
          )
        )

        expect(user.praxis_balance).to eq(0)
        expect(user.reload.black_market_purchases).to be_blank
        expect(punk.reload.animated_at).to be_blank

        expect(BlackMarket::ProductPriceIncreaser).not_to receive(:call).with(product)
      end
    end
  end
end
