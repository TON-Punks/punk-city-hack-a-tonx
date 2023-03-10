# frozen_string_literal: true

require "rails_helper"

RSpec.describe Missions::NeuroboxLevel::Contributor do
  let(:user) { create(:user, prestige_level: 5, experience: 200) }
  let!(:mission) { Missions::NeuroboxLevelMission.create(user: user, state: :running) }

  specify do
    2.times { described_class.call(user: user) }
    expect(mission.reload.levels_count).to eq(2)
  end

  context "when mission can be finished" do
    let!(:mission) { Missions::NeuroboxLevelMission.create(user: user, state: :running, data: { levels_count: 100 }) }

    specify do
      expect(Telegram::Notifications::Lootboxes::NeuroboxLevelReceived).to receive(:call).with(user: user)
      described_class.call(user: user)
      expect(user.lootboxes.count).to eq(1)
      expect(mission.reload.state).to eq("completed")
    end
  end
end
