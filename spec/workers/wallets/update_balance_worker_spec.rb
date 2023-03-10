require 'rails_helper'

RSpec.describe Wallets::UpdateBalanceWorker do
  subject { described_class.new.perform(wallet.id) }

  let(:wallet) { create(:wallet) }

  specify do
    expect(Wallets::UpdateBalance).to receive(:call).with(wallet: wallet)

    subject
  end
end
