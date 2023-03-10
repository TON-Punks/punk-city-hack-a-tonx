require 'rails_helper'

RSpec.describe Praxis::FastExchange::RateCalculator do
  subject { described_class.call(user_id) }

  let(:user_id) { rand(100) }
  let(:exchange_rate) { 0.2 }
  let(:multiplier_manager) { instance_double(Praxis::FastExchange::MultiplierManager) }

  before do
    allow(Praxis::FastExchange::MultiplierManager).to receive(:new).with(user_id).and_return(multiplier_manager)
    allow(multiplier_manager).to receive(:exchange_rate).and_return(exchange_rate)
  end

  specify do
    expect(subject.exp).to eq(1250)
    expect(subject.praxis).to eq(250)
  end
end
