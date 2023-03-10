# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::ValidateCompleteness do
  let(:game) { create :rock_paper_scissors_game, address: address, blockchain_state: :active }
  context 'complete case' do
    let(:address) { 'EQDUDfYuzTAfmSEFqi6bcw3gRIcTvsf5ykAXllj3Rzrz9-aa' }

    around { |e| VCR.use_cassette("rock_paper_scissors_games/account", &e) }

    specify do
      described_class.call(game: game)

      game.reload
      expect(game).to be_blockchain_complete
    end
  end

  context 'incomplete case' do
    let(:address) { 'EQAQw3JpXuDnSBzXpP1H292bK2b1OPBEVq6LBPoCEcgBrq3T' }

    context "when both moves wasn't deployed" do
      specify do
        VCR.use_cassette "rock_paper_scissors_games/incomplete_account" do
          described_class.call(game: game)
        end

        game.reload
        expect(game).to be_blockchain_incomplete
      end
    end

    context "when one move bounced" do
      let(:opponent) { create(:wallet, base64_address_bounce: 'EQCN0H50jZp1ZjmHNgdFy-KrXNTnHzTDYw0ywa7Px0SnJVeB').user }
      let(:creator) { create(:wallet, base64_address_bounce: 'EQAhJw_z5nTyvy0nKEd1g8B7BmrgHO6vq8qNrNG5Bcj4ApcH').user }
      let(:address) { 'EQAMSMTwXwdpagnXOv6T9hrSO8Uh-C0yKA6EcDtjwxWZYlMd' }

      before do
        game.update(opponent: opponent, creator: creator)
      end

      specify do
        expect(RockPaperScissorsGames::SendMove).to receive(:call).with(game: game, user_type: 'opponent')

        VCR.use_cassette "rock_paper_scissors_games/incomplete_account_one_move_bounce" do
          described_class.call(game: game)
        end
      end
    end


    context "when one move wasn't deployed" do
      let(:opponent) { create(:wallet, base64_address_bounce: 'EQAhJw_z5nTyvy0nKEd1g8B7BmrgHO6vq8qNrNG5Bcj4ApcH').user }
      let(:creator) { create(:wallet, base64_address_bounce: 'EQCN0H50jZp1ZjmHNgdFy-KrXNTnHzTDYw0ywa7Px0SnJVeB').user }
      let(:address) { 'EQD34R5itAYYbhlW6fp63esnfpVcF0UXukGmggYN9l4i4JHn' }

      before do
        game.update(opponent: opponent, creator: creator)
      end

      specify do
        expect(RockPaperScissorsGames::SendMove).to receive(:call).with(game: game, user_type: 'creator')

        VCR.use_cassette "rock_paper_scissors_games/incomplete_account_one_move_missing" do
          described_class.call(game: game)
        end
      end
    end
  end
end
