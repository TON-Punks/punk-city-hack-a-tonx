# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::TonReferralRewardDistribution do
  describe "#call" do
    let(:game) do
      create(:rock_paper_scissors_game, bet: 2_000_000_000, bet_currency: :ton, creator: creator, opponent: opponent,
        state: :creator_won)
    end

    let(:creator) { create(:user) }
    let(:opponent) { create(:user) }
    let(:creator_referred_by) { create(:user) }
    let(:opponent_referred_by) { create(:user) }

    context "when referred by user present" do
      before do
        Referral.create(user: creator_referred_by, referred: creator)
        Referral.create(user: opponent_referred_by, referred: opponent)
      end

      specify do
        expect(BlackMarket::ComissionPayoutWorker)
          .to receive(:perform_in).with(1.minute, creator_referred_by.id, 0.02)
        expect(BlackMarket::ComissionPayoutWorker)
          .to receive(:perform_in).with(3.minutes, opponent_referred_by.id, 0.02)
        described_class.call(game: game)
      end
    end

    context "when no referred by user present" do
      specify do
        expect(BlackMarket::ComissionPayoutWorker).not_to receive(:perform_in)
        described_class.call(game: game)
      end
    end
  end
end
