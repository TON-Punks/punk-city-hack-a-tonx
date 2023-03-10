# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::CreateGame do
  let(:creator) { create(:wallet, virtual_balance: 1_000_000_000).user }
  let(:game) do
    build :rock_paper_scissors_game, visibility: :public, bet: 500_000, bet_currency: :ton, creator: creator
  end

  specify do
    expect(game).to receive(:send_creation_notifications)
    expect(RockPaperScissorsGames::JoinByBotWorker).to receive(:perform_in)

    expect { described_class.call(game: game) }.to change { RockPaperScissorsGame.count }.by(1)
  end

  context "when similar game exists" do
    before { create :rock_paper_scissors_game, visibility: :public, bet: 500_000, bet_currency: :ton }

    specify do
      expect(RockPaperScissorsGames::DeployGame).to receive(:call)
      expect(RockPaperScissorsGames::JoinGame).to receive(:call).and_call_original

      result = described_class.call(game: game)
      expect(result.joined).to eq(true)
      expect(result.creator_versus_image).to be_present
      expect(result.opponent_versus_image).to be_present
      expect(game).to_not be_persisted
    end
  end

  context "when praxis-betted game" do
    let(:praxis_creator) { create(:user) }
    before do
      praxis_creator.praxis_transactions.regular_exchange.create!(quantity: 700_000)
      create :rock_paper_scissors_game, visibility: :public, bet: 500_000, bet_currency: :praxis,
        creator: praxis_creator
    end

    specify do
      expect(game).to receive(:send_creation_notifications)
      expect(RockPaperScissorsGames::JoinByBotWorker).to receive(:perform_in)

      expect { described_class.call(game: game) }.to change { RockPaperScissorsGame.count }.by(1)
    end
  end
end
