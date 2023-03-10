require 'rails_helper'

RSpec.describe Praxis::Withdraw do
  subject { described_class.call(user: user, receiving_address: receiving_address, praxis_amount: praxis_amount) }

  let(:user) { create(:user) }
  let(:receiving_address) { "receiving_address" }
  let(:praxis_amount) { 777 }

  context "when receiving wallet is unknown" do
    let(:receiving_address) { "receiving_address" }

    specify do
      expect(BlackMarket::TonPaymentProcessor).not_to receive(:call)
      expect { subject }.not_to change(PraxisTransaction, :count)
      expect(subject).not_to be_success
    end
  end

  context "when receiving wallet is known" do
    let(:receiver) { create(:user) }
    let(:receiver_wallet) { create(:wallet, user: receiver) }

    let(:receiving_address) { [receiver_wallet.base64_address_bounce, receiver_wallet.base64_address].sample }

    context "when receiving praxis amount is invalid" do
      let(:praxis_amount) { [499, 5001].sample }

      before { user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: 15000) }

      specify do
        expect(BlackMarket::TonPaymentProcessor).not_to receive(:call)
        expect { subject }.not_to change(PraxisTransaction, :count)
        expect(subject).not_to be_success
        expect(subject.error_message).to eq(I18n.t("bank.withdraw.errors.invalid_praxis_amount", praxis: praxis_amount, praxis_min: described_class::MIN, praxis_max: described_class::MAX))
      end
    end

    context "when user has not enough praxis" do
      let(:praxis_amount) { 1777 }

      before { user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: 1500) }

      specify do
        expect(BlackMarket::TonPaymentProcessor).not_to receive(:call)
        expect { subject }.not_to change(PraxisTransaction, :count)
        expect(subject).not_to be_success
      end
    end

    context "when user has not enough praxis to cover comission" do
      let(:praxis_amount) { 1777 }

      before { user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: 1800) }

      specify do
        expect(BlackMarket::TonPaymentProcessor).not_to receive(:call)
        expect { subject }.not_to change(PraxisTransaction, :count)
        expect(subject).not_to be_success
      end
    end

    context "when ton fee payment failed" do
      let(:ton_payment_result) { OpenStruct.new(success?: false, error_message: 'error_message') }
      let(:praxis_amount) { 1000 }

      before do
        user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: 1800)
        allow(BlackMarket::TonPaymentProcessor).to receive(:call).with(ton_price: described_class::TON_FEE, user: user)
          .and_return(ton_payment_result)
      end

      specify do
        expect { subject }.not_to change(PraxisTransaction, :count)
        expect(subject).not_to be_success
      end
    end
  end

  context "when enough praxis and ton fee payment successfull" do
    let(:receiver) { create(:user) }
    let(:receiver_wallet) { create(:wallet, user: receiver) }
    let(:receiving_address) { [receiver_wallet.base64_address_bounce, receiver_wallet.base64_address].sample }

    let(:ton_payment_result) { OpenStruct.new(success?: true) }
    let(:praxis_amount) { 1000 }

    before do
      user.praxis_transactions.create(operation_type: PraxisTransaction::REGULAR_EXCHANGE, quantity: 1800)
      allow(BlackMarket::TonPaymentProcessor).to receive(:call).with(ton_price: described_class::TON_FEE, user: user)
        .and_return(ton_payment_result)
    end

    specify do
      expect(Telegram::Notifications::NewPraxisTransaction).to receive(:call)
        .with(user: receiver, praxis_amount: praxis_amount, praxis_sender: user.username)
      expect { subject }.to change(PraxisTransaction, :count).by(2)
      expect(subject).to be_success

      expect(user.praxis_balance).to eq(700)
      expect(receiver.praxis_balance).to eq(1000)
    end
  end
end
