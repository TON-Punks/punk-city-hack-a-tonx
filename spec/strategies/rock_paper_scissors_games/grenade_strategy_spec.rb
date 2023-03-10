# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::GrenadeStrategy do
  describe '#pick_move' do
    let(:game) { create :rock_paper_scissors_game }

    include_examples 'first move strategy', :grenade

    context 'when next round' do
      let(:aggressive_moves) do
        %i[grenade annihilation].map { |name| RockPaperScissorsGame::NAME_TO_MOVE[name] }
      end

      let(:safe_moves) do
        %i[katana hack pistol].map { |name| RockPaperScissorsGame::NAME_TO_MOVE[name] }
      end

      context 'when healthier' do
        it 'with low chance choses aggressive move' do
          expect(SecureRandom).to receive(:rand).and_return(0.1)
          move = described_class.new(game: game, rounds_count: 2, total_damage: { 'opponent' => 0, 'creator' => 20 }).pick_move

          expect(aggressive_moves).to include(move)
        end
      end

      context 'when hurt' do
        it 'with low chance choses safe move' do
          expect(SecureRandom).to receive(:rand).and_return(0.9)
          move = described_class.new(game: game, rounds_count: 2, total_damage: { 'opponent' => 20, 'creator' => 0 }).pick_move

          expect(safe_moves).to include(move)
        end
      end
    end
  end
end
