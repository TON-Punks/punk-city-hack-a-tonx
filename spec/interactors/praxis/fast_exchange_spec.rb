# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::FastExchange do
  subject { described_class.call(user: user) }

  let(:user) { create(:user, prestige_level: 5, experience: 130) }

  let(:multiplier_manager) { instance_double(Praxis::FastExchange::MultiplierManager) }
  let(:exp_rate) { 100 }
  let(:praxis_rate) { 10 }
  let(:rate_calculator_result) { Praxis::FastExchangeRate.new(exp: exp_rate, praxis: praxis_rate) }

  before do
    allow(Praxis::FastExchange::RateCalculator).to receive(:call).with(user.id).and_return(rate_calculator_result)
    allow(Praxis::FastExchange::MultiplierManager).to receive(:new).with(user.id).and_return(multiplier_manager)
  end

  specify do
    expect(multiplier_manager).to receive(:increase)

    subject

    expect(user.reload.experience).to eq(30)
    expect(user.praxis_balance).to eq(praxis_rate)
  end

  context 'when user has less experience than required' do
    let(:exp_rate) { 200 }

    specify do
      expect(multiplier_manager).not_to receive(:increase)

      expect(subject.error_message).to eq(I18n.t("bank.fast_exchange.errors.insufficient_experience"))

      expect(user.reload.experience).to eq(130)
      expect(user.praxis_balance).to eq(0)
    end
  end

  context 'when user has linked punk' do
    before { user.punk = create(:punk, number: 0, experience: 140) }

    specify do
      expect(multiplier_manager).to receive(:increase)

      subject

      expect(user.punk.reload.experience).to eq(40)
      expect(user.praxis_balance).to eq(praxis_rate)
    end

    context 'when punk has less experience than required' do
      let(:exp_rate) { 200 }

      specify do
        expect(multiplier_manager).not_to receive(:increase)

        expect(subject.error_message).to eq(I18n.t("bank.fast_exchange.errors.insufficient_experience"))

        expect(user.punk.reload.experience).to eq(140)
        expect(user.praxis_balance).to eq(0)
      end
    end
  end
end
