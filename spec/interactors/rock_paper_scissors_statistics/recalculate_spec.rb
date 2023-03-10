# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsStatistics::Recalculate do
  let(:user) { create :user }
  let(:creator) { create :user }
  let(:statistic) { create :rock_paper_scissors_statistic, user: user }

  before do
    creator.praxis_transactions.regular_exchange.create!(quantity: 200_000)
    user.praxis_transactions.game_won.create!(quantity: 10_000)
    user.praxis_transactions.game_lost.create!(quantity: 500)
    create :rock_paper_scissors_game, creator: user, state: :archived
    create_list :rock_paper_scissors_game, 2, creator: user, state: :creator_won
    create_list :rock_paper_scissors_game, 3, creator: user, state: :opponent_won
    create_list :rock_paper_scissors_game, 2, opponent: user, state: :opponent_won, bet: 100_000, bet_currency: :ton
    create :rock_paper_scissors_game, opponent: user, state: :creator_won, bet: 100_000, bet_currency: :ton
    create_list :rock_paper_scissors_game, 2, creator: creator, opponent: user, state: :opponent_won, bet: 200,
      bet_currency: :praxis
    create :rock_paper_scissors_game, creator: creator, opponent: user, state: :creator_won, bet: 100,
      bet_currency: :praxis
  end

  specify "call" do
    described_class.call(statistic: statistic)

    statistic.reload
    expect(statistic.ton_won).to eq(360_000)
    expect(statistic.ton_lost).to eq(100_000)
    expect(statistic.praxis_won).to eq(10_000)
    expect(statistic.praxis_lost).to eq(500)
    expect(statistic.games_lost).to eq(5)
    expect(statistic.games_won).to eq(6)
    expect(statistic.winrate).to eq(0.55)
  end
end
