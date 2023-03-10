# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameRounds::CalculateWinner do
  describe 'call' do
    let(:game) { create :rock_paper_scissors_game, :started }

    def generate_game_round(creator_name, opponent_name)
      GameRound.new(
        'creator' => RockPaperScissorsGame::NAME_TO_MOVE[creator_name],
        'opponent' => RockPaperScissorsGame::NAME_TO_MOVE[opponent_name]
      )
    end

    subject(:result) do
      GameRounds::CalculateWinner.call(game_round: game_round, total_damage: game.total_damage, always_proc: true)
    end

    shared_examples 'calculates round correctly' do |creator_name, opponent_name, winner|
      context "when #{creator_name} and #{opponent_name}" do
        let(:game_round) { generate_game_round(creator_name, opponent_name) }

        it { expect(result.winner.to_s).to eq(winner.to_s) }
      end
    end

    include_examples "calculates round correctly", :hack, :grenade, :creator
    include_examples "calculates round correctly", :hack, :pistol, :opponent
    include_examples "calculates round correctly", :hack, :annihilation, :creator
    include_examples "calculates round correctly", :hack, :katana, :opponent
    include_examples "calculates round correctly", :hack, :hack, ''

    include_examples "calculates round correctly", :katana, :grenade, :opponent
    include_examples "calculates round correctly", :katana, :pistol, :creator
    include_examples "calculates round correctly", :katana, :annihilation, :opponent
    include_examples "calculates round correctly", :katana, :hack, :creator
    include_examples "calculates round correctly", :katana, :katana, ''

    include_examples "calculates round correctly", :annihilation, :katana, :creator
    include_examples "calculates round correctly", :annihilation, :hack, :opponent
    include_examples "calculates round correctly", :annihilation, :grenade, :creator
    include_examples "calculates round correctly", :annihilation, :pistol, :opponent
    include_examples "calculates round correctly", :annihilation, :annihilation, ''

    include_examples "calculates round correctly", :pistol, :annihilation, :creator
    include_examples "calculates round correctly", :pistol, :katana, :opponent
    include_examples "calculates round correctly", :pistol, :hack, :creator
    include_examples "calculates round correctly", :pistol, :grenade, :opponent
    include_examples "calculates round correctly", :pistol, :pistol, ''

    include_examples "calculates round correctly", :grenade, :annihilation, :opponent
    include_examples "calculates round correctly", :grenade, :katana, :creator
    include_examples "calculates round correctly", :grenade, :hack, :opponent
    include_examples "calculates round correctly", :grenade, :pistol, :creator
    include_examples "calculates round correctly", :grenade, :grenade, ''

    describe 'modifiers' do
      context 'when hack wins' do
        let(:game_round) { generate_game_round(:hack, :grenade) }

        context 'when no damage was done' do
          specify do
            expect(result.loser_modifier).to eq(:heal)
            expect(result.loser_damage).to eq(0)
          end
        end

        xcontext 'with damage' do
          before do
            create :game_round, rock_paper_scissors_game: game, winner_damage: 10, winner: :opponent
          end

          specify do
            result = GameRounds::CalculateWinner.call(game_round: game_round, total_damage: game.total_damage, always_proc: true)

            expect(result.loser_modifier).to eq(:heal)
            expect(result.loser_damage).to be < 0
          end
        end
      end

      context 'when grenade vs katana' do
        let(:game_round) { generate_game_round(:grenade, :katana) }

        specify do
          expect(result.winner_modifier).to eq(:miss)
        end
      end

      context 'when annihilation vs pistol' do
        let(:game_round) { generate_game_round(:annihilation, :grenade) }

        specify do
          expect(result.winner_modifier).to eq(:critical)
        end
      end
    end
  end
end
