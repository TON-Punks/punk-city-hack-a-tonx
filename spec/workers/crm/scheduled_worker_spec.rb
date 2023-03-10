require 'rails_helper'

RSpec.describe Crm::ScheduledWorker do
  subject(:perform) { described_class.new.perform }

  let(:user) { create(:user, onboarded: false, locale: :ru) }
  let(:triggerable_crm) { instance_double(Crm::Onboarding::Missing::Day1) }
  let(:participant) { true }

  before do
    create(:ab_testing_experiment_crm, user: user, participates: participant)
    allow(Crm::Onboarding::Missing::Day1).to receive(:new).with(user).and_return(triggerable_crm)
    allow(triggerable_crm).to receive(:executable?).and_return(true)
    user.segments << Segments::Crm.fetch(Segments::Crm::BEGINNER)
  end

  specify do
    expect(triggerable_crm).to receive(:perform)

    perform
  end

  context "when not participant" do
    let(:participant) { false }

    specify do
      expect(triggerable_crm).not_to receive(:perform)

      perform
    end
  end
end
