# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::ScheduleBotGameCreation do
  include RedisHelper

  let!(:bot_user) { create :user, :bot }
  let(:redis_key) { RockPaperScissorsGames::ScheduleBotGameCreation::LAST_GAME_CREATED_KEY }

  describe "#call" do
    before { create :wallet, user: bot_user, virtual_balance: 100_000_000_000 }

    context "when game wasn't created for some time" do
      before { redis.set(redis_key, 5.hours.ago.to_i) }
      specify do
        expect(RockPaperScissorsGames::CancelBotGameWorker).to receive(:perform_in)
        expect(RockPaperScissorsGames::SendNotificationsWorker).to receive(:perform_async)
        expect { described_class.call }.to change { RockPaperScissorsGame.count }.by(1)

        game = RockPaperScissorsGame.last
        expect(game.creator).to eq(bot_user)
        expect(game.bet).to be_between(500_000_000, 2_500_000_000)
        expect(game.bot).to eq(true)
        expect(game.bot_strategy).to be_present
      end
    end

    context "when game was recently created" do
      before { redis.set(redis_key, 1.hours.ago.to_i) }

      specify do
        expect { described_class.call }.to_not change(RockPaperScissorsGame, :count)
      end
    end

    context "when bot account doesn't have money" do
      before { bot_user.wallet.update(virtual_balance: 0) }

      specify do
        expect do
          described_class.call
        end.to raise_error(RockPaperScissorsGames::ScheduleBotGameCreation::GAME_CREATION_ERROR)
      end
    end
  end
end
