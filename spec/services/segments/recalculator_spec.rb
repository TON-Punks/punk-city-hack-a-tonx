require 'rails_helper'

RSpec.describe Segments::Recalculator do
  describe ".call" do
    subject { described_class.call(segment) }

    let(:user) { create(:user) }
    let(:segment) { Segments::Crm }
    let(:matching_segment_name) { Segments::Crm::REGULAR_PAYER }

    before do
      allow(Segments::Rules::Fetcher).to receive(:call).with(user, segment).and_return(matching_segment_name)
    end

    context "when user has no segment assigned" do
      it "assigns segment" do
        subject

        expect(user.segment_for(Segments::Crm).name).to eq(matching_segment_name)
      end
    end

    context "when user already has same segment assigned" do
      before { user.segments << Segments::Crm.fetch(matching_segment_name) }

      it "doesn't re-assign" do
        expect { subject }.not_to change { user.segments_users.first.id }

        expect(user.segment_for(Segments::Crm).name).to eq(matching_segment_name)
      end
    end

    context "when user already has another segment assigned" do
      before { user.segments << Segments::Crm.fetch(Segments::Crm::BEGINNER) }

      it "replaces segment with new one" do
        expect { subject }.to change { user.segments_users.last.id }

        expect(user.segment_for(Segments::Crm).name).to eq(matching_segment_name)
      end
    end

    context "when user no longer relates to segment" do
      let(:matching_segment_name) { nil }

      it "deletes segment" do
        subject

        expect(user.segment_for(Segments::Crm)).to be_nil
      end
    end
  end
end
