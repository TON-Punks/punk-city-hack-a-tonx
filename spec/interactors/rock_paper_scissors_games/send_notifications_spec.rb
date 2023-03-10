# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::SendNotifications do
  let(:game) { create :rock_paper_scissors_game, bet: 20, bet_currency: :ton }

  describe "call" do
    let(:message_id) { "1234" }
    let(:telegram_response) { { "result" => { "message_id" => message_id } } }

    before do
      expect(TelegramApi).to receive(:send_message)
        .and_return(double(parsed_response: telegram_response, success?: true)).exactly(notifications_count).times
    end
    let(:notifications_count) { 3 }

    specify do
      described_class.call(game: game)

      expect(game.notifications.count).to eq(notifications_count)
      expect(game.notifications.first.message_id).to eq(message_id)
      expect(game.notifications.pluck(:temporary)).to eq([true, true, true])
    end

    context "when praxis bet is 299" do
      let(:user) { create(:user) }
      let(:game) { create :rock_paper_scissors_game, bet: 299, bet_currency: :praxis, creator: user }
      let(:notifications_count) { 2 }

      before do
        user.praxis_transactions.regular_exchange.create!(quantity: 500)
      end

      it "doesn't send notification to sapiens" do
        described_class.call(game: game)

        expect(game.notifications.count).to eq(notifications_count)
        expect(game.notifications.first.message_id).to eq(message_id)
        expect(game.notifications.pluck(:temporary)).to eq([true, true])
      end
    end
  end
end
