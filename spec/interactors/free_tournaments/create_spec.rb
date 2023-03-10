# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::Create do
  describe "call" do
    subject { described_class.call }

    context "when tournament running" do
      before { create(:free_tournament, start_at: 1.day.ago, finish_at: 1.day.from_now) }

      it { is_expected.not_to be_success }
    end

    context "when tournament already scheduled" do
      before { create(:free_tournament, start_at: 1.day.from_now, finish_at: 3.days.from_now) }

      it { is_expected.not_to be_success }
    end

    context "when no tournament planned" do
      before { create(:free_tournament, start_at: 10.days.ago, finish_at: 9.days.ago) }

      specify do
        expect(Segments::RecalculationWorker).to receive(:perform_async).with(Segments::FreeTournament.name)

        expect { subject }.to change(FreeTournament, :count)
      end
    end
  end
end
