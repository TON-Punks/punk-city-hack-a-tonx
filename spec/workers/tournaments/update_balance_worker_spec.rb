require 'rails_helper'

RSpec.describe Tournaments::UpdateBalanceWorker do
  subject { described_class.new.perform(tournament.id) }

  let(:tournament) { create(:tournament) }

  specify do
    expect(Tournaments::UpdateBalance).to receive(:call).with(tournament: tournament)

    subject
  end
end
