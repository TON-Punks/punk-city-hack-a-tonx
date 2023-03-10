# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::SendMovesWorker do
  context 'default case' do
    let(:game) { create :rock_paper_scissors_game, address: "EQDUDfYuzTAfmSEFqi6bcw3gRIcTvsf5ykAXllj3Rzrz9-aa" }

    around { |e| VCR.use_cassette("rock_paper_scissors_games/account", &e) }

    specify do
      expect(RockPaperScissorsGames::SendMoves).to receive(:call)

      described_class.new.perform(game.id)
    end
  end

  context 'game is inactive' do
    let(:game) { create :rock_paper_scissors_game, address: "EQDJtQ19LiY07Qq_cFkrP9OEkXHXLh4mkjaSCcdDdAdQE1hZ" }

    around { |e| VCR.use_cassette("rock_paper_scissors_games/inactive_account", &e) }

    specify do
      expect(RockPaperScissorsGames::SendMovesWorker).to receive(:perform_in).with(60, game.id, true)

      described_class.new.perform(game.id)
    end

    context 'second attempt' do
      specify do
        expect(RockPaperScissorsGames::DeployGame).to receive(:call)
        expect(RockPaperScissorsGames::SendMovesWorker).to receive(:perform_in).with(120, game.id, false)

        described_class.new.perform(game.id, true)
      end
    end
  end
end
