# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::RecalculateStatistics do
  describe "call" do
    subject { described_class.call }

    let(:tournament) { create(:free_tournament, start_at: 1.day.ago, finish_at: 1.hour.from_now, prize_amount: 13_000) }
    let(:segment) { Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT) }

    let(:first_participant) { create(:user) }
    let(:second_participant) { create(:user) }
    let(:not_participant) { create(:user) }

    before do
      first_participant.segments << segment
      second_participant.segments << segment
      tournament.statistic_for_user(first_participant).update(score: 30)
      tournament.statistic_for_user(second_participant).update(score: 28)
      tournament.statistic_for_user(not_participant).update(score: 42)
    end

    specify do
      subject
      expect(tournament.statistic_for_user(first_participant).position).to eq(1)
      expect(tournament.statistic_for_user(first_participant).reward).to eq(2600)
      expect(tournament.statistic_for_user(second_participant).position).to eq(2)
      expect(tournament.statistic_for_user(second_participant).reward).to eq(2080)
      expect(tournament.statistic_for_user(not_participant).position).to be_nil
      expect(tournament.statistic_for_user(not_participant).reward).to be_nil
    end
  end
end
