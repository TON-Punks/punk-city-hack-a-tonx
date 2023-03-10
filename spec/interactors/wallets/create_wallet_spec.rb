# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wallets::CreateWallet do
  let(:user) { create :user }
  describe 'call' do
    specify do
      expect { described_class.call(user: user) }.to change { Wallet.count }.by(1)

      wallet = Wallet.last
      expect(wallet.credential.public_key).to be_present
      expect(wallet.credential.secret_key).to be_present
      expect(wallet.credential.mnemonic).to be_present
      expect(wallet.user).to eq(user)
      expect(wallet.address).to be_present
      expect(wallet.base64_address).to be_present
      expect(wallet.base64_address_bounce).to be_present
    end
  end
end
