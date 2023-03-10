require "rails_helper"

RSpec.describe Segments::Rules::Crm::Beginner do
  describe ".call" do
    subject { described_class.call(user) }

    let(:user) { create(:user) }

    it { is_expected.to be_truthy }

    context "when played game" do
      before { create(:rock_paper_scissors_game, creator: user) }

      it { is_expected.to be_falsey }
    end
  end
end
