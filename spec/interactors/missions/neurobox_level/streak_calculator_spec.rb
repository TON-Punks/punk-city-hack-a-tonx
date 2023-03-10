require "rails_helper"

RSpec.describe Missions::NeuroboxLevel::StreakCalculator do
  subject { described_class.call(user: user).level }

  let(:user) { build_stubbed(:user, prestige_level: prestige_level) }

  context "when level 305" do
    let(:prestige_level) { 305 }

    it { is_expected.to eq(1) }
  end

  context "when level 201" do
    let(:prestige_level) { 201 }

    it { is_expected.to eq(1) }
  end

  context "when level 901" do
    let(:prestige_level) { 901 }

    it { is_expected.to eq(1) }
  end

  context "when level 83" do
    let(:prestige_level) { 83 }

    it { is_expected.to eq(2) }
  end

  context "when level 0" do
    let(:prestige_level) { 0 }

    it { is_expected.to eq(4) }
  end
end
