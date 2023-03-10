# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::RegularExchange do
  include RedisHelper

  subject { described_class.call(user: user) }

  let(:exp) { 1500 }
  let(:user) { create(:user, experience: exp) }

  let(:interval) { 600 }
  let(:time_calculator_result) do
    Praxis::RegularExchangeTime.new(
      interval: interval,
      until_reset: 100.0,
      humanized_interval: '1m',
      humanized_until_reset: '2m',
      humanized_ongoing_interval: ''
    )
  end

  before do
    allow(Praxis::RegularExchange::TimeCalculator).to receive(:call).with(user).and_return(time_calculator_result)
  end

  specify do
    expect(Praxis::RegularExchangeWorker).to receive(:perform_in).with(interval, user.id)

    subject

    expect(redis.exists?("regular-exchange-user-blocked-#{user.id}")).to be_truthy
  end

  context 'when user already queued regular exchange' do
    before { redis.setex("regular-exchange-user-blocked-#{user.id}", 10000, "1") }

    specify do
      expect(subject.error_message).to eq(I18n.t("bank.regular_exchange.errors.already_queued"))
    end
  end

  context 'when user already queued regular exchange' do
    let(:exp) { 100 }

    specify do
      expect(subject.error_message).to eq(I18n.t("bank.fast_exchange.errors.insufficient_experience"))
    end
  end
end
