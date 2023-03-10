require "rails_helper"

RSpec.describe Segments::Rules::Crm::ChampionPayer do
  describe ".call" do
    subject { described_class.call(user) }

    let(:user) { create(:user) }

    it { is_expected.to be_falsey }

    context "when played 10 free game last month" do
      before { 10.times { create(:rock_paper_scissors_game, bet: 1, bet_currency: :ton, creator: user) } }

      it { is_expected.to be_truthy }
    end
  end
end
