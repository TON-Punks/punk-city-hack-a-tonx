require 'rails_helper'

RSpec.describe Segments::Crm, type: :model do
  describe ".fetch" do
    subject { described_class.fetch(name) }

    context "when unknown name" do
      let(:name) { 'some unknown random' }

      it "raises UNKNOWN_SEGMENT_NAME_ERROR" do
        expect { subject }.to raise_error(described_class::UNKNOWN_SEGMENT_NAME_ERROR)
      end
    end

    context "when valid name" do
      let(:name) { described_class.available_names.sample }

      context "when first time fetched" do
        it "creates and returns entity" do
          expect { subject }.to change(Segments::Crm, :count).by(1)
        end
      end

      context "when second time fetched" do
        it "doesn't create new entity" do
          expect { described_class.fetch(name) }.to change(Segments::Crm, :count).by(1)
          expect { described_class.fetch(name) }.not_to change(Segments::Crm, :count)
        end
      end
    end
  end
end
