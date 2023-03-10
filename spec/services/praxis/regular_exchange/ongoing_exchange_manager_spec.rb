require 'rails_helper'

RSpec.describe Praxis::RegularExchange::OngoingExchangeManager do
  subject { described_class.new(user.id) }

  let(:user) { create(:user) }

  specify do
    expect(subject.time_left).to be_nil
    subject.set_time_left(100)
    expect(subject.time_left).to be_within(2).of(100)
  end
end
