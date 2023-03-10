require "rails_helper"

RSpec.describe RockPaperScissorsGames::JoinByBots::PaidBotFetcher do
  subject { described_class.call(game_id: game.id) }

  let(:bot_strategy) { :random }
  let(:game) { create(:rock_paper_scissors_game, bet: game_bet, bet_currency: :ton) }
  let(:game_bet) { 1300 }

  let(:first_bot) { create(:user) }
  let(:second_bot) { create(:user) }
  let(:bot_with_low_balance) { create(:user) }

  let(:first_bot_virtual_balance) { 2000 }
  let(:second_bot_virtual_balance) { 1500 }
  let(:bot_with_low_virtual_balance) { 1200 }

  before do
    allow(RockPaperScissorsGame::PAID_GAMES_STRATEGIES).to receive(:sample).and_return(bot_strategy)
    allow(TelegramConfig).to receive(:bot_ids).and_return([first_bot.id, second_bot.id, bot_with_low_balance.id])

    create(:wallet, user: first_bot, virtual_balance: first_bot_virtual_balance)
    create(:wallet, user: second_bot, virtual_balance: second_bot_virtual_balance)
    create(:wallet, user: bot_with_low_balance, virtual_balance: bot_with_low_virtual_balance)
  end

  context "when game bet is greater than max threshold" do
    let(:game_bet) { 1_000_000 }

    it { is_expected.not_to be_success }
  end

  context "when game bet is lower than 5 ton" do
    context "when there are no bots with balance" do
      let(:first_bot_virtual_balance) { 0 }
      let(:second_bot_virtual_balance) { 0 }
      let(:bot_with_low_virtual_balance) { 0 }

      it { is_expected.not_to be_success }
    end

    context "when one bot recently played 1 game" do
      before { create(:rock_paper_scissors_game, bot: true, bet: 1300, bet_currency: :ton, opponent_id: second_bot.id) }

      it "chooses this bot" do
        expect(subject).to be_success
        expect(subject.bot_id).to eq(second_bot.id)
        expect(subject.bot_strategy).to eq(bot_strategy)
      end
    end

    context "when one bot recently played 7 games" do
      before do
        7.times do
          create(:rock_paper_scissors_game, bot: true, bet: 1300, bet_currency: :ton, opponent_id: second_bot.id,
            created_at: 1.minutes.ago)
        end
      end

      it "chooses bot with blank history" do
        expect(subject).to be_success
        expect(subject.bot_id).to eq(first_bot.id)
        expect(subject.bot_strategy).to eq(bot_strategy)
      end
    end
  end
end
