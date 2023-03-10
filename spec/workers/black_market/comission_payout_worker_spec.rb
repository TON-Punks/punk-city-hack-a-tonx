# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackMarket::ComissionPayoutWorker do
  subject(:perform) { described_class.new.perform(user.id, ton_fee) }

  let(:user) { create(:user) }
  let(:ton_fee) { rand }

  specify do
    expect(BlackMarket::ComissionPayoutProcessor).to receive(:call).with(user: user, ton_fee: ton_fee)

    perform
  end
end
