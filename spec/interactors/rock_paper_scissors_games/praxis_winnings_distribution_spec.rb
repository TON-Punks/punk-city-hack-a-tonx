# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::PraxisWinningsDistribution do
  describe "#call" do
    subject { described_class.call(game: game) }

    let(:game) do
      create(:rock_paper_scissors_game, bet: 200, bet_currency: :praxis, creator: creator, opponent: opponent,
        state: :opponent_won)
    end

    let(:creator) { create(:user) }
    let(:opponent) { create(:user) }
    let(:opponent_referred_by) { create(:user) }
    let(:creator_referred_by) { create(:user) }

    before do
      Referral.create(user: opponent_referred_by, referred: opponent)
      Referral.create(user: creator_referred_by, referred: creator)

      creator.praxis_transactions.regular_exchange.create!(quantity: 1000)
      opponent.praxis_transactions.regular_exchange.create!(quantity: 2000)

      opponent.praxis_transactions.reserved.create!(quantity: 200)
    end

    specify do
      subject

      expect(creator.praxis_balance).to eq(800)
      expect(opponent.praxis_balance).to eq(2160)
      expect(opponent_referred_by.praxis_balance).to eq(2)
      expect(creator_referred_by.praxis_balance).to eq(2)
    end
  end
end
