# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::CreateResultsImage do
  let(:opponent) { create(:user) }

  let(:game_id) { 120 }
  let(:game) { create(:rock_paper_scissors_game, opponent: opponent, id: game_id) }

  before { opponent.punk = build(:punk, prestige_level: 3) }

  after do
    File.delete("tmp/results-image-#{game_id}-for-#{game.creator.id}.png")
    File.delete("tmp/results-image-#{game_id}-for-#{game.opponent.id}.png") unless game.opponent.bot?
  end

  specify do
    described_class.call(game: game)

    expect(File).to exist(Rails.root.join("tmp/results-image-#{game_id}-for-#{game.creator.id}.png"))
    expect(File).to exist(Rails.root.join("tmp/results-image-#{game_id}-for-#{game.opponent.id}.png"))
  end

  context "when game is with bot" do
    let(:opponent) { create(:user, :bot) }

    specify do
      described_class.call(game: game)

      expect(File).to exist(Rails.root.join("tmp/results-image-#{game_id}-for-#{game.creator.id}.png"))
      expect(File).to_not exist(Rails.root.join("tmp/results-image-#{game_id}-for-#{game.opponent.id}.png"))
    end
  end
end
