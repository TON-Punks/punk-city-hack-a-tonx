# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::Finalize do
  describe "call" do
    subject { described_class.call }

    let(:tournament) { create(:free_tournament, start_at: 1.day.ago, finish_at: 1.hour.ago, prize_amount: 1000) }

    let(:winner) { create(:user) }
    let(:looser) { create(:user) }

    before do
      allow(FreeTournaments::RecalculateStatistics).to receive(:call).with(tournament: tournament)
      allow(FreeTournaments::Leaderboard::Generate).to receive(:call).with(tournament: tournament)
      tournament.statistic_for_user(winner).update(reward: 100)
      tournament.statistic_for_user(looser).update(reward: 0)
    end

    specify do
      expect(Telegram::Notifications::FreeTournaments::UserWon).to receive(:call)
        .with(tournament: tournament, user: winner)
      expect(Telegram::Notifications::FreeTournaments::UserLost).to receive(:call)
        .with(tournament: tournament, user: looser)

      subject

      expect(tournament.reload).to be_finished

      expect(winner.reload.praxis_balance).to eq(100)
      expect(looser.reload.praxis_balance).to eq(0)
    end
  end
end
