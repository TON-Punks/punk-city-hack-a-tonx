# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::ContributePrizePool do
  describe ".call" do
    subject { described_class.call(game: game) }

    let(:game) { build_stubbed(:rock_paper_scissors_game, bet_currency: bet_currency, bet: 500) }
    let(:bet_currency) { :praxis }

    context "when tournament running" do
      let!(:tournament) do
        create(:free_tournament, start_at: 1.day.ago, finish_at: 1.day.from_now, prize_amount: 10,
          dynamic_prize_enabled: true)
      end

      context "when ton game" do
        let(:bet_currency) { :ton }

        specify do
          expect(subject).not_to be_success
          expect(tournament.reload.prize_amount).to eq(10)
        end
      end

      context "when praxis game" do
        let(:bet_currency) { :praxis }

        specify do
          expect(subject).to be_success
          expect(tournament.reload.prize_amount).to eq(35)
        end
      end
    end

    context "when not dynamic prize pool" do
      let!(:tournament) do
        create(:free_tournament, start_at: 1.day.ago, finish_at: 1.day.from_now, prize_amount: 10,
          dynamic_prize_enabled: false)
      end

      it { is_expected.not_to be_success }
    end

    context "when no tournament running" do
      it { is_expected.not_to be_success }
    end
  end
end
