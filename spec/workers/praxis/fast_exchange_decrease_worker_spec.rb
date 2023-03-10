# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::FastExchangeDecreaseWorker do
  subject(:perform) { described_class.new.perform(user_id) }

  let(:user_id) { rand(100) }
  let(:multiplier_manager) { instance_double(Praxis::FastExchange::MultiplierManager) }

  specify do
    expect(Praxis::FastExchange::MultiplierManager).to receive(:new).with(user_id).and_return(multiplier_manager)
    expect(multiplier_manager).to receive(:decrease)

    perform
  end
end
