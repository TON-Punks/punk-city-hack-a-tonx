require "rails_helper"

RSpec.describe UserPraxisWallet do
  let(:user) { create(:user) }

  describe "#balance" do
    subject { described_class.new(user).balance }

    before do
      user.praxis_transactions.regular_exchange.create!(quantity: 10_000)
      user.praxis_transactions.game_lost.create!(quantity: 3_000)
    end

    it { is_expected.to eq(7_000) }
  end

  describe "#reserve" do
    subject { described_class.new(user).reserve(amount) }

    context "when amount to reserve is more than balance" do
      let(:amount) { 11_001 }

      before { user.praxis_transactions.regular_exchange.create!(quantity: 11_000) }

      it { expect { subject }.to raise_error(described_class::INVALID_AMOUNT_ERROR) }
    end

    context "when amount to reserve is equal to balance" do
      let(:amount) { 10_000 }

      before { user.praxis_transactions.regular_exchange.create!(quantity: 10_000) }

      it do
        subject

        expect(described_class.new(user).balance).to eq(0)
      end
    end

    context "when amount to reserve is less than balance" do
      let(:amount) { 9_999 }

      before { user.praxis_transactions.regular_exchange.create!(quantity: 10_000) }

      it do
        subject

        expect(described_class.new(user).balance).to eq(1)
      end
    end
  end

  describe "#unreserve" do
    subject { described_class.new(user).unreserve(amount) }

    before do
      user.praxis_transactions.regular_exchange.create!(quantity: 11_000)
      user.praxis_transactions.reserved.create!(quantity: 10_000)
    end

    context "when amount to unreserve is more than reserved balance" do
      let(:amount) { 10_001 }

      it { expect { subject }.to raise_error(described_class::INVALID_AMOUNT_ERROR) }
    end

    context "when amount to unreserve is equal to reserved balance" do
      let(:amount) { 10_000 }

      it do
        subject

        expect(described_class.new(user).balance).to eq(11_000)
      end
    end

    context "when amount to unreserve is less than reserved balance" do
      let(:amount) { 9_999 }

      it do
        subject

        expect(described_class.new(user).balance).to eq(10_999)
      end
    end
  end
end
