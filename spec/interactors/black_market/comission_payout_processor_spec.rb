# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlackMarket::ComissionPayoutProcessor do
  include RedisHelper

  subject { described_class.call(user: user, ton_fee: ton_fee) }

  before { create(:wallet, user: user) }

  let(:user) { create(:user) }
  let(:ton_fee) { 0.1 }

  context "when processing frozen" do
    before { redis.set("black-market-comission-withdraw", "1") }

    after { redis.del("black-market-comission-withdraw") }

    it "reschedules job" do
      expect(BlackMarket::ComissionPayoutWorker).to receive(:perform_in).with(2.minutes.to_i, user.id, ton_fee)

      subject
    end
  end

  it "withdraws correctly" do
    expect(subject).to be_success
  end
end
