require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'wallet_credentials' do
    let(:wallet) { create :wallet }
    let!(:wallet_credential) { create :wallet_credential, wallet: wallet }

    it { expect(wallet.credential).to eq(wallet_credential)  }
  end
end
