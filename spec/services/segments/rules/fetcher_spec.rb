require "rails_helper"

RSpec.describe Segments::Rules::Fetcher do
  describe ".call" do
    subject { described_class.call(user, segment_type) }

    let(:user) { create(:user, onboarded: true) }
    let(:segment_type) { Segments::Crm }

    it "returns beginner segment" do
      expect(subject).to eq(Segments::Crm::BEGINNER)
    end
  end
end
