require "rails_helper"

RSpec.describe Inventory::CollectItem do
  subject { described_class.call(item_user: item_user) }

  let(:user) { create(:user, prestige_level: 5) }
  let(:item_user) { create(:items_user, item: item, user: user) }

  context "when item is experience" do
    let(:item) { create(:experience_item) }

    it "adds experience to user" do
      subject
      expect(subject).to be_success
      expect(subject.quantity).to be_positive
      expect(user.experience).to eq(3300)
    end
  end

  context "when item is praxis" do
    let(:item) { create(:praxis_item) }

    it "adds praxis to user" do
      subject
      expect(subject).to be_success
      expect(subject.quantity).to be_positive
      expect(user.praxis_transactions.neurobox_lite.count).to be_positive
    end
  end

  context "when item is weapon" do
    let(:item) { create(:weapon_item) }

    it { is_expected.not_to be_success }
  end
end
