require "rails_helper"

RSpec.describe RockPaperScissorsGame, type: :model do
  let(:user) { create(:wallet).user }
  let(:game) { create :rock_paper_scissors_game }

  describe "send_creation_notifications" do
    let(:game) { create :rock_paper_scissors_game, :with_opponent, bet: 100, bet_currency: :ton }

    specify do
      expect(RockPaperScissorsGames::SendNotificationsWorker).to receive(:perform_async)

      game.send_creation_notifications
    end

    context "when private" do
      before { game.update(visibility: :private) }
      specify do
        expect(RockPaperScissorsGames::SendNotificationsWorker).to_not receive(:perform_async)

        game.send_creation_notifications
      end
    end
  end

  describe "callbacks" do
    before { user.unlock_game_creation! }

    context "when created" do
      specify do
        expect { described_class.create!(creator: user) }.to change { user.can_start_new_game? }.from(true).to(false)
      end
    end

    context "when started" do
      let(:game) { create :rock_paper_scissors_game, :with_opponent }

      context "common case" do
        before do
          create :rock_paper_scissors_notification, rock_paper_scissors_game: game
          expect(RockPaperScissorsGames::UpdateNotificationsWorker).to receive(:perform_async).with(game.id)
        end

        specify do
          expect(RockPaperScissorsGames::FreeGamesCounter).to receive(:increment)

          expect { game.start! }.to change { game.opponent.can_start_new_game? }.from(true).to(false)
        end
      end

      context "when paid" do
        let(:opponent) { create(:wallet).user }
        let(:game) { create :rock_paper_scissors_game, bet: 100, bet_currency: :ton, opponent: opponent }

        specify do
          expect(RockPaperScissorsGames::DeployGame).to receive(:call)
          expect(game.opponent.wallet).to receive(:reserve)

          game.start!
        end
      end
    end

    context "before destroy" do
      let(:game) { create :rock_paper_scissors_game, creator: user, bet: 100, bet_currency: :ton }
      before do
        stub_telegram
        create :rock_paper_scissors_notification, rock_paper_scissors_game: game, temporary: true
        create :rock_paper_scissors_notification, rock_paper_scissors_game: game
      end

      specify do
        expect(user.wallet).to receive(:unreserve).with(100)

        expect { game.destroy! }.to change { game.notifications.count }.by(-2)
      end
    end

    describe "archived" do
      let(:game) { create :rock_paper_scissors_game, creator: user, bet: 100, bet_currency: :ton }

      specify do
        expect(game.creator.wallet).to receive(:unreserve).with(100)

        game.archive!
      end
    end
  end

  describe "scopes" do
    describe "visibility" do
      let!(:public_game) { create :rock_paper_scissors_game, creator: user }
      let!(:private_game) { create :rock_paper_scissors_game, creator: user, visibility: :private }

      specify do
        expect(described_class.private_visibility.to_a).to eq([private_game])
        expect(described_class.public_visibility.to_a).to eq([public_game])
      end
    end

    describe ".with_latest_round_before" do
      before do
        create :game_round, rock_paper_scissors_game: game, created_at: 6.minutes.ago
        create :game_round, rock_paper_scissors_game: game, created_at: 4.minutes.ago
      end

      specify do
        expect(described_class.with_latest_round_before(5.minutes.ago)).to be_empty
        expect(described_class.with_latest_round_before(3.minutes.ago)).to eq([game])
      end
    end
  end

  describe "make_move" do
    context "when bot" do
      before { skip 'bot games unsupported without proper user' }

      let(:user) { create :user }
      let(:game) { create :rock_paper_scissors_game, :started, creator: user, bot: true, bot_strategy: :random }
      let(:round) do
        double(GameRound, winner: "creator", winner_damage: 10, loser_damage: 0, winner_modifier: nil,
          loser_modifier: nil)
      end

      before { allow(GameRounds::CalculateWinner).to receive(:call).and_return(round) }

      it do
        game.make_move!(from: user, move: 2)
        expect(game).to be_started
        expect(game.game_rounds.size).to eq(1)
        expect(game.game_rounds.last.winner).to eq("creator")

        game.make_move!(from: user, move: 1)
        expect(game.reload.game_rounds.size).to eq(2)
        expect(game.game_rounds.last.winner).to eq("creator")

        game.make_move!(from: user, move: 1)
        expect(game.reload.game_rounds.size).to eq(3)
        expect(game.game_rounds.last.winner).to eq("creator")

        allow(game).to receive(:total_damage).and_return({ "opponent" => 0, "creator" => 40 })

        game.make_move!(from: user, move: 1)
        expect(game.reload.game_rounds.size).to eq(4)
        expect(game.game_rounds.last.winner).to eq("creator")

        expect(game.creator_won?).to eq(true)
      end
    end

    context "when user" do
      before do
        expect(RockPaperScissorsGames::DeployGame).to receive(:call)
        expect(RockPaperScissorsGames::SendMovesWorker).to receive(:perform_async)
        game.start!
      end

      let(:opponent_wallet) { create :wallet, balance: 40_000_000 }
      let!(:creator_wallet) { create :wallet, balance: 40_000_000, user: user }
      let(:opponent) { opponent_wallet.user }

      let(:game) do
        create :rock_paper_scissors_game, creator: user, opponent: opponent, bot: false, bet: 20_000_000,
          bet_currency: :ton
      end

      let!(:another_opponent_game) do
        RockPaperScissorsGame.create(creator: opponent, bot: false, bet: 20_000_000, bet_currency: :ton)
      end
      let!(:another_creator_game) do
        RockPaperScissorsGame.create(creator: user, bot: false, bet: 20_000_000, bet_currency: :ton)
      end

      xit "one always wins" do
        round = double(GameRound, winner: "creator", winner_damage: 14, loser_damage: 0, winner_modifier: nil,
          loser_modifier: nil)
        allow(GameRounds::CalculateWinner).to receive(:call).and_return(round)

        game.make_move!(from: user, move: 1)
        expect(game.game_rounds.last.creator).to eq(1)

        game.make_move!(from: opponent, move: 2)
        expect(game.game_rounds.size).to eq(1)
        expect(game.game_rounds.last.creator).to eq(1)
        expect(game.game_rounds.last.opponent).to eq(2)
        expect(game.game_rounds.last.winner).to eq("creator")
        game.reload

        game.make_move!(from: user, move: 1)
        expect(game.game_rounds.reload.size).to eq(2)
        expect(game.game_rounds.last.creator).to eq(1)

        game.make_move!(from: opponent, move: 2)
        game.game_rounds.reload
        expect(game.game_rounds.size).to eq(2)
        expect(game.game_rounds.last.creator).to eq(1)
        expect(game.game_rounds.last.opponent).to eq(2)
        expect(game.game_rounds.last.winner).to eq("creator")
        game.reload

        game.make_move!(from: user, move: 1)
        expect(game.game_rounds.size).to eq(3)
        expect(game.game_rounds.last.creator).to eq(1)

        allow(game).to receive(:total_damage).and_return({ "opponent" => 0, "creator" => 40 })

        game.make_move!(from: opponent, move: 2)
        game.game_rounds.reload
        expect(game.game_rounds.size).to eq(3)
        expect(game.game_rounds.last.creator).to eq(1)
        expect(game.game_rounds.last.opponent).to eq(2)
        expect(game.game_rounds.last.winner).to eq("creator")

        expect(game).to be_creator_won
        expect(another_creator_game.reload).to be_created
        expect(another_opponent_game.reload).to be_archived
      end
    end
  end

  describe "experience" do
    let(:game) do
      create :rock_paper_scissors_game, opponent: create(:user), state: :started, bet_currency: bet_currency
    end

    context "when paid" do
      let(:bet_currency) { :ton }

      before do
        game.parse_bet("40.112345")
        game.opponent_win!
      end

      specify do
        expect(game.opponent_experience).to eq(2587)
        expect(game.creator_experience).to eq(2572)
      end
    end

    context "when free" do
      let(:bet_currency) { nil }

      before { game.opponent_win! }

      specify do
        expect(game.opponent_experience).to eq(30)
        expect(game.creator_experience).to eq(8)
      end
    end
  end

  describe "force_close!" do
    let(:game) { create :rock_paper_scissors_game, :started, :with_opponent }

    before { expect(RockPaperScissorsGames::SendGameCloseNotificationsWorker).to receive(:perform_async).with(game.id) }

    context "when opponent made move" do
      let!(:game_round) { create :game_round, rock_paper_scissors_game: game, opponent: 2, creator: nil }

      it "opponent won" do
        game.force_close!

        expect(game.reload).to be_opponent_won
      end
    end

    context "when creator made move" do
      let!(:game_round) { create :game_round, rock_paper_scissors_game: game, opponent: nil, creator: 2 }

      it "creator won" do
        game.force_close!

        expect(game.reload).to be_creator_won
      end
    end

    context "casual" do
      let!(:game_round) do
        create :game_round, rock_paper_scissors_game: game, winner: "creator", opponent: 3, creator: 2
      end

      it "archiving for now" do
        game.force_close!

        expect(game.reload).to be_archived
      end
    end

    context "draw" do
      let!(:game_round) do
        create :game_round, rock_paper_scissors_game: game, opponent: 2, creator: 2, winner: nil
      end

      specify do
        game.force_close!

        expect(game.reload).to be_archived
      end
    end
  end

  describe "parse_bet" do
    let(:game) { create :rock_paper_scissors_game }

    specify do
      game.parse_bet("-1")
      game.reload
      expect(game.bet).to eq(0)
    end
  end

  describe 'cache weapons' do
    let(:weapons) { Items::Weapons::DEFAULT.map { Item.build_from_data(:weapon, _1) } }
    let(:grouped_weapons) { weapons.index_by(&:position) }
    let(:game) { create :rock_paper_scissors_game, :with_opponent }

    before do
      game.opponent.items = weapons
      game.creator.items = weapons

      game.opponent.items_users.each(&:equip!)
      game.creator.items_users.each(&:equip!)
    end

    specify do
      game.cache_weapons

      expect(game.cached_weapons[game.opponent.id].keys).to match_array([1, 2, 3, 4, 5])
      expect(game.cached_weapons[game.creator.id].keys).to match_array([1, 2, 3, 4, 5])

      expect(game.cached_weapons[game.opponent.id].values.flatten).to eq(weapons)
      expect(game.cached_weapons[game.creator.id].values.flatten).to eq(weapons)

      expect(game.cached_items_users[game.opponent.id]).to eq(game.opponent.items_users)
      expect(game.cached_items_users[game.creator.id]).to eq(game.creator.items_users)
    end
  end
end
