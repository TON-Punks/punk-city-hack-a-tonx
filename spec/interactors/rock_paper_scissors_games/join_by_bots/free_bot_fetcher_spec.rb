require 'rails_helper'

RSpec.describe RockPaperScissorsGames::JoinByBots::FreeBotFetcher do
  subject { described_class.call(game_id: 777) }

  let(:bot_id) { 100 }
  let(:bot_strategy) { :random }

  before do
    allow(RockPaperScissorsGame::PAID_GAMES_STRATEGIES).to receive(:sample).and_return(bot_strategy)
    allow(TelegramConfig.bot_ids).to receive(:sample).and_return(bot_id)
  end

  specify do
    expect(subject).to be_success
    expect(subject.bot_id).to eq(bot_id)
    expect(subject.bot_strategy).to eq(bot_strategy)
  end
end
