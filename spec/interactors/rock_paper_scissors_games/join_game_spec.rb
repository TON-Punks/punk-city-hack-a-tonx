# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::JoinGame do
  describe "call" do
    subject(:result) { described_class.call(arguments) }

    let(:creator) { create(:wallet).user }
    let(:game) { create :rock_paper_scissors_game, creator: creator, state: :created }
    let(:opponent) { create(:wallet).user }
    let(:arguments) { { game_id: game.id, user: opponent } }

    describe "success" do
      specify do
        expect(result).to be_success
        expect(result.game).to eq(game)
        expect(result.game.opponent).to eq(opponent)
        expect(result.game.bot?).to eq(false)
      end

      context "when bot" do
        let(:arguments) { { game_id: game.id, user: opponent, bot: true, bot_strategy: :katana } }

        specify do
          expect(result).to be_success
          expect(result.game).to eq(game)
          expect(result.game.opponent).to eq(opponent)
          expect(result.game.bot?).to eq(true)
          expect(result.game.bot_strategy).to eq("katana")
        end
      end
    end

    describe "errors" do
      context "when game has too high bet" do
        before do
          game.update(bet: 10_000_000, bet_currency: :ton)
          creator.wallet.update(balance: 100_000_000)
          opponent.wallet.update(balance: 1_000_000)
        end

        specify do
          expect(result).to be_failure
          expect(result.error).to eq("Недостаточно денег на счете для этой игры")
        end
      end
      context "when no game_id" do
        let(:arguments) { {} }

        specify do
          expect(result).to be_failure
          expect(result.error).to eq("Игра не найдена")
        end
      end

      context "when game_id is gibberish" do
        let(:arguments) { { game_id: 100_500 } }

        specify do
          expect(result).to be_failure
          expect(result.error).to eq("Игра не найдена")
        end
      end

      context "when game already started" do
        let(:game) { create :rock_paper_scissors_game, opponent: create(:user) }
        let(:arguments) { { game_id: game.id } }

        specify do
          expect(result).to be_failure
          expect(result.error).to eq("Не удалось присоединиться. Игра уже началась")
        end
      end

      context "when game archived" do
        let(:game) { create :rock_paper_scissors_game, state: :archived }
        let(:arguments) { { game_id: game.id } }

        specify do
          expect(result).to be_failure
          expect(result.error).to eq("Не удалось присоединиться. Игра не активна")
        end
      end

      context "when game creator is in another game" do
        let(:arguments) { { game_id: game.id } }

        before { create(:rock_paper_scissors_game, creator: creator, state: :started) }

        specify do
          expect(result).to be_failure
          expect(result.error).to eq("Пожалуйста, попробуйте позже. Игрок находится в другом бою")
        end
      end

      context "when lock is already taken" do
        let(:game) { create :rock_paper_scissors_game }
        let(:arguments) { { game_id: game.id } }
        let(:meta) { Class.new }
        before { meta.extend(RedisHelper) }

        specify do
          meta.with_lock "game_join-#{game.id}" do |_locked|
            expect(result).to be_failure
            expect(result.error).to eq("Не удалось присоединиться. Игра уже началась")
          end
        end
      end
    end
  end
end
