# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::CalibrationStats do
  describe "call" do
    subject { described_class.call(user: user) }

    let(:user) { create(:user) }

    before do
      create(:free_tournament, start_at: 1.day.ago, finish_at: 1.day.from_now)
      user.praxis_transactions.regular_exchange.create!(quantity: 10)
      create(:rock_paper_scissors_game, bet_currency: :praxis, bet: 1, creator: user, state: :creator_won)
      create(:rock_paper_scissors_game, bet_currency: :ton, bet: 10, creator: user, state: :opponent_won)
    end

    specify do
      expect(subject.stats).to eq({
        ton_games_left: 3,
        praxis_games_left: 4,
        free_games_left: 7
      })
    end
  end
end
