require "rails_helper"

RSpec.describe RockPaperScissorsGames::FreeGamesMatchmaking do
  subject { described_class.can_be_matched?(creator, user) }

  let(:creator) { create(:user) }
  let(:user) { create(:user) }

  context "when less than 10 battles" do
    it { is_expected.to be_truthy }
  end

  context "when more than 10 battles with 0.5 threshold" do
    before do
      5.times { create(:rock_paper_scissors_game, creator: creator, opponent: user, state: :creator_won) }
      5.times { create(:rock_paper_scissors_game, creator: user, opponent: creator, state: :creator_won) }
    end

    it { is_expected.to be_truthy }
  end

  context "when more than 10 battles with one player always winning" do
    before do
      8.times { create(:rock_paper_scissors_game, creator: creator, opponent: user, state: :creator_won) }
      2.times { create(:rock_paper_scissors_game, creator: user, opponent: creator, state: :creator_won) }
    end

    it { is_expected.to be_falsey }
  end
end
