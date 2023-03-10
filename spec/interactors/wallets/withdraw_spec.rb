# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wallets::Withdraw do
  let(:wallet) { create :wallet, balance: 90_728_626, virtual_balance: 90_728_626 }
  let(:withdraw_request) { create :withdraw_request, wallet: wallet, address: 'EQBaazYTFs4FxFbh2CyFMhpwkgVsEbrqRjp0YG-yW2VcsHEz' }

  before do
    create :wallet_credential,
      wallet: wallet,
      public_key: '371f887e6752fd0c18637de503dbf017674cbc1b5cc640d5774c79729c5faef8',
      secret_key: 'b94613931d3fca6d139201560a83607c0bd231e0bd773028e6a33a6ad07d9b2d371f887e6752fd0c18637de503dbf017674cbc1b5cc640d5774c79729c5faef8'

    withdraw_request.parse_amount!('0.05')
  end

  it 'withdraws correctly' do
    described_class.call(withdraw_request: withdraw_request, dry_run: true)

    expect(wallet.reload.balance).to eq(40728626)
    expect(wallet.reload.virtual_balance).to eq(40728626)
  end

  context 'when trying to withdrawn more than exists' do
    before { withdraw_request.parse_amount!('0.5') }

    it 'fails' do
      result = described_class.call(withdraw_request: withdraw_request, dry_run: true)

      expect(result).to_not be_success
      expect(wallet.reload.balance).to eq(90728626)
    end
  end

  context 'when trying above reserved sum' do
    before { wallet.update(virtual_balance: 0) }

    it 'fails' do
      result = described_class.call(withdraw_request: withdraw_request, dry_run: true)

      expect(result).to_not be_success
      expect(wallet.reload.balance).to eq(90728626)
    end
  end
end
