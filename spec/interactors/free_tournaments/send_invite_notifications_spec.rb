# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::SendInviteNotifications do
  describe "call" do
    subject { described_class.call }

    let(:user) { create(:user) }

    before { user.segments << Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT) }

    context "when no tournament scheduled or running" do
      before { create(:free_tournament, start_at: 10.days.ago, finish_at: 9.days.ago) }

      it { is_expected.not_to be_success }
    end

    context "when tournament running" do
      context "when tournament started recently" do
        before { create(:free_tournament, start_at: 20.hours.ago, finish_at: 1.day.from_now) }

        specify do
          expect(Telegram::Notifications::FreeTournaments::FirstDay).to receive(:call).with(user: user)
          subject
        end
      end

      context "when tournament running for 3 days" do
        before { create(:free_tournament, start_at: 50.hours.ago, finish_at: 1.day.from_now) }

        specify do
          expect(Telegram::Notifications::FreeTournaments::ThirdDay).to receive(:call).with(user: user)
          subject
        end
      end
    end
  end
end
