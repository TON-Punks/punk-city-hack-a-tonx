require 'rails_helper'

RSpec.describe WithdrawRequest, type: :model do
  let(:wallet) { create :wallet }
  let(:request) { create :withdraw_request, wallet: wallet, amount: 7162565697490}

  subject { request }

  its(:user) { is_expected.to eq(wallet.user) }
  its(:pretty_amount) { is_expected.to eq('7162.56569749') }

  it { expect(request.parse_amount!('762.5678')).to eq 762567800000 }
  it { expect(request.parse_amount!('0.56')).to eq 560000000 }
end
