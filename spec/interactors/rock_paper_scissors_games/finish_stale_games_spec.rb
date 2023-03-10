# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::FinishStaleGames do
  let(:game) { create :rock_paper_scissors_game, :started, :with_opponent }

  context "when no one moved at all" do
    let!(:game) { create :rock_paper_scissors_game, :started, updated_at: 10.minutes.ago }

    specify do
      described_class.call

      expect(game.reload).to be_archived
    end
  end

  context "with game round" do
    before do
      create :game_round, rock_paper_scissors_game: game, created_at: 12.minutes.ago, **attributes
    end

    context "when opponent doesn't move" do
      let(:attributes) { { creator: 1, opponent: nil } }

      specify do
        described_class.call
        expect(game.reload).to be_creator_won
      end
    end

    context "when creator doesn't move" do
      let(:attributes) { { creator: nil, opponent: 1 } }

      specify do
        described_class.call
        expect(game.reload).to be_opponent_won
      end
    end

    context "when no one made a second move" do
      let(:attributes) { {} }

      specify do
        described_class.call
        expect(game.reload).to be_archived
      end
    end
  end
end
