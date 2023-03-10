require 'rails_helper'

RSpec.describe Praxis::RegularExchange::TimeCalculator do
  include RedisHelper

  subject { described_class.call(user) }

  let(:user) { create(:user) }
  let(:current_time) { Time.now.utc }

  before do
    Praxis::RegularExchange::OngoingExchangeManager.new(user.id).set_time_left(9990)
    Timecop.freeze(2022, 9, 1, 23, 0)
    create(:praxis_transaction, user: user, operation_type: :regular_exchange, created_at: 2.days.ago)
    create(:praxis_transaction, user: user, operation_type: :regular_exchange, created_at: 1.minute.ago)
    create(:praxis_transaction, user: user, operation_type: :regular_exchange, created_at: 2.hour.ago)
  end

  after { Timecop.return }

  specify do
    expect(subject.interval).to eq(10800)
    expect(subject.until_reset).to eq(current_time.end_of_day - current_time)
    expect(subject.humanized_interval).to eq("3ч")
    expect(subject.humanized_ongoing_interval).to eq("2ч 46м")
  end
end
