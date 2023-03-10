# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::JoinByBot do
  let(:game) { create(:rock_paper_scissors_game) }
  let(:bot_user) { create(:user, :bot) }
  let(:bot_strategy) { :random }

  context "when paid game" do
    before do
      allow(RockPaperScissorsGame).to receive(:find).with(game.id).and_return(game)
      allow(game).to receive(:free?).and_return(false)
      allow(RockPaperScissorsGames::JoinByBots::PaidBotFetcher).to receive(:call).with(game_id: game.id)
                                                                                 .and_return(paid_result)
    end

    context "when paid bot result success" do
      let(:paid_result) { OpenStruct.new(success?: true, bot_id: bot_user.id, bot_strategy: bot_strategy) }

      specify do
        expect(RockPaperScissorsGames::JoinGame)
          .to receive(:call).with(game_id: game.id, user: bot_user, bot: true, bot_strategy: bot_strategy)
          .and_call_original

        expect(Telegram::Callback::Fight).to receive(:call)

        described_class.call(game_id: game.id)
      end
    end

    context "when paid bot result failed" do
      let(:paid_result) { OpenStruct.new(success?: false) }

      specify do
        expect { described_class.call(game_id: game.id) }.to raise_error(described_class::NoAvailableBotsError)
      end
    end
  end

  context "when free game" do
    before do
      allow(RockPaperScissorsGames::JoinByBots::FreeBotFetcher).to receive(:call).with(game_id: game.id)
                                                                                 .and_return(paid_result)
    end

    context "when free bot result success" do
      let(:paid_result) { OpenStruct.new(success?: true, bot_id: bot_user.id, bot_strategy: bot_strategy) }

      specify do
        expect(RockPaperScissorsGames::JoinGame)
          .to receive(:call).with(game_id: game.id, user: bot_user, bot: true, bot_strategy: bot_strategy)
          .and_call_original

        expect(Telegram::Callback::Fight).to receive(:call)

        described_class.call(game_id: game.id)
      end
    end

    context "when free bot result failed" do
      let(:paid_result) { OpenStruct.new(success?: false) }

      specify do
        expect { described_class.call(game_id: game.id) }.to raise_error(described_class::NoAvailableBotsError)
      end
    end
  end

  context "when join is unsuccessful" do
    let(:game) { create(:rock_paper_scissors_game, bet: 5, bet_currency: :ton) }
    let(:paid_result) { OpenStruct.new(success?: true, bot_id: bot_user.id, bot_strategy: bot_strategy) }

    before do
      game.archived!
      allow(RockPaperScissorsGames::JoinByBots::PaidBotFetcher).to receive(:call).with(game_id: game.id)
                                                                                 .and_return(paid_result)
    end

    specify do
      expect { described_class.call(game_id: game.id) }.to raise_error(described_class::JoinError)
    end
  end
end
