# frozen_string_literal: true

require "rails_helper"

RSpec.describe Missions::NeuroboxLevel::Validator do
  describe "#call" do
    subject { described_class.call(user: user) }

    let(:user) { create(:user) }

    it { expect(subject.available).to be_truthy }
  end
end
