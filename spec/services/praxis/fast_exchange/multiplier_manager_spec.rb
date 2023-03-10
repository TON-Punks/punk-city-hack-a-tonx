require 'rails_helper'

RSpec.describe Praxis::FastExchange::MultiplierManager do
  let(:user_id) { rand(100) }
  let(:current_time) { Time.now.utc.change(usec: 0) }

  before { Timecop.freeze }

  after { Timecop.return }

  describe '.exchange_rate' do
    subject { described_class.new(user_id) }

    specify do
      expect(subject.exchange_rate).to eq(0.08)
      expect(subject.current_multiplier).to eq(20)
    end
  end

  describe '.increase' do
    subject { described_class.new(user_id) }

    specify do
      expect(Praxis::FastExchangeDecreaseWorker).to receive(:perform_in).with(current_time + 600, user_id)

      subject.increase

      expect(subject.current_multiplier).to eq(21)
      expect(subject.exchange_rate).to eq(0.079)
    end
  end

  describe '.decrease' do
    subject { described_class.new(user_id) }

    let(:current_time) { Time.now.utc.change(usec: 0) }

    specify do
      expect(Praxis::FastExchangeDecreaseWorker).to receive(:perform_in).with(current_time + 600, user_id)
      expect(Praxis::FastExchangeDecreaseWorker).to receive(:perform_in).with(current_time + 1200, user_id).twice

      3.times { subject.increase }
      subject.decrease

      expect(subject.current_multiplier).to eq(22)
      expect(subject.exchange_rate).to eq(0.078)
    end
  end
end
