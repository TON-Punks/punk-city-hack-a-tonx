# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::RepeatStrategy do
  let(:total_damage) { { 'opponent' => 0, 'creator' => 20 } }
  let(:game) { create :rock_paper_scissors_game }
  let(:all_moves) { [1, 2, 3, 4, 5] }

  def pick_move
    described_class.new(game: game, rounds_count: rand(1..100), total_damage: total_damage).pick_move
  end

  before { allow(RockPaperScissorsGame::NAME_TO_MOVE).to receive(:values).and_return(all_moves) }

  describe '#pick_move' do
    context 'when no previous moves' do
      let(:random_move) { 2 }

      before do
        allow(all_moves).to receive(:sample).and_return(random_move)
        allow(SecureRandom).to receive(:rand).and_return(0.1)
      end

      specify 'it selects random move from full list' do
        expect(pick_move).to eq(random_move)
      end
    end

    context 'when one previous move' do
      before { allow(SecureRandom).to receive(:rand).and_return(0.9) }

      specify 'it returns the same' do
        first_move = pick_move
        expect(pick_move).to eq(first_move)
        expect(pick_move).not_to eq(first_move)
      end
    end

    context 'when two previous moves' do
      context 'when selecting from all moves' do
        before { allow(SecureRandom).to receive(:rand).and_return(0.1) }

        specify 'it returns new move' do
          first_move = pick_move
          second_move = pick_move
          allow(all_moves).to receive(:sample).and_return(first_move)
          expect(pick_move).to eq(first_move)
        end
      end

      context 'when selecting from not used moves' do
        before { allow(SecureRandom).to receive(:rand).and_return(0.4) }

        specify 'it returns new move' do
          first_move = pick_move
          second_move = pick_move
          allow(all_moves).to receive(:sample).and_return(first_move)
          expect(pick_move).not_to eq(first_move)
        end
      end
    end

    context 'when many previous moves' do
      specify 'it returns random move from all moves' do
        13.times { pick_move }
        expect(all_moves).to include(pick_move)
      end
    end
  end
end
