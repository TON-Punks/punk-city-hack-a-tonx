# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::ValidateCreatorBalance do
  let(:wallet) { create :wallet }
  let(:opponent) { create(:wallet).user }
  let(:game) do
    create :rock_paper_scissors_game, creator: wallet.user, opponent: opponent, bet: 2000, bet_currency: :ton
  end

  context "when still can pay" do
    before { wallet.update(virtual_balance: RockPaperScissorsGame::SEND_MESSAGE_FEE + 2000) }

    specify do
      expect { described_class.call(game: game) }.to_not change(game, :state)
    end
  end

  context "when can't play anymore" do
    before { wallet.update(virtual_balance: 0) }

    specify do
      expect { described_class.call(game: game) }.to change { game.reload.state }.to("archived")
    end
  end
end
