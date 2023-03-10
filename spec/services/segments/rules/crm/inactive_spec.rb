require "rails_helper"

RSpec.describe Segments::Rules::Crm::Inactive do
  describe ".call" do
    subject { described_class.call(user) }

    let(:user) { create(:user) }

    it { is_expected.to be_falsey }

    context "when played game 40 days ago" do
      before { create(:rock_paper_scissors_game, creator: user, created_at: 40.days.ago) }

      it { is_expected.to be_truthy }
    end
  end
end
