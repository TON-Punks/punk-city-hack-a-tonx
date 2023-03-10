# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::CalibrationProcessor do
  describe "call" do
    subject { described_class.call(user: user) }

    let(:user) { create(:user) }

    let(:stats) { { ton_games_left: ton_games_left, praxis_games_left: 2, free_games_left: 3 } }

    before do
      allow(FreeTournaments::CalibrationStats).to receive(:call).with(user: user)
                                                                .and_return(OpenStruct.new(stats: stats))
    end

    context "when condition matches" do
      let(:ton_games_left) { 0 }

      specify do
        expect(Telegram::Notifications::FreeTournaments::CalibrationPassed).to receive(:call).with(user: user)
        subject
        expect(user.segments.first).to eq(Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT))
      end
    end

    context "when condition doesn't match" do
      let(:ton_games_left) { 1 }

      specify do
        subject
        expect(user.segments).to be_blank
      end
    end
  end
end
