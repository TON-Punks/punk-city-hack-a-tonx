# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::RegularExchangeWorker do
  subject(:perform) { described_class.new.perform(user.id) }

  let(:user) { create(:user, experience: experience) }
  let(:experience) { 1200 }

  specify do
    expect(Telegram::Notifications::RegularExchangeCompleted).to receive(:call).with(user: user, praxis: 100)

    perform

    expect(user.reload.experience).to eq(200)
    expect(user.praxis_balance).to eq(100)
  end

  context "when user has not enough exp" do
    let(:experience) { 100 }

    specify do
      expect(Telegram::Notifications::RegularExchangeCompleted).not_to receive(:call)

      perform

      expect(user.reload.experience).to eq(experience)
      expect(user.praxis_balance).to eq(0)
    end
  end
end
