# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::TonExchange do
  subject { described_class.call(user: user, rate: Praxis::TonExchange::RateFetcher::SMALL) }

  let(:user) { create(:user, prestige_level: 5) }
  let(:request) { instance_doruble(WithdrawRequest) }

  let(:rate_name) { Praxis::TonExchange::RateFetcher::SMALL }
  let(:rate) { Praxis::TonExchange::RateFetcher::RATES.fetch(rate_name) }

  let(:ton_payment_result) { OpenStruct.new(success?: true) }

  before do
    allow(BlackMarket::TonPaymentProcessor).to receive(:call).with(ton_price: rate.ton, user: user).and_return(ton_payment_result)
  end

  specify do
    subject

    expect(user.praxis_balance).to eq(rate.praxis)
  end

  context 'when user has not enough ton for comission or rate reached' do
    let(:ton_payment_result) { OpenStruct.new(success?: false, error_message: 'error_message') }

    specify do
      expect(subject.error_message).to eq('error_message')
      expect(user.praxis_balance).to eq(0)
    end
  end
end
