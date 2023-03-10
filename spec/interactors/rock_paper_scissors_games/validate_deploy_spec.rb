# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::ValidateDeploy do
  let(:game) { create :rock_paper_scissors_game, address: "EQDUDfYuzTAfmSEFqi6bcw3gRIcTvsf5ykAXllj3Rzrz9-aa" }

  describe 'call' do
    around { |e| VCR.use_cassette("rock_paper_scissors_games/account", &e) }

    specify do
      described_class.call(game: game)

      game.reload
      expect(game).to be_blockchain_active
    end
  end
end
