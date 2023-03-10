# frozen_string_literal: true

require "rails_helper"

RSpec.describe Missions::NeuroboxLevel::ResetHandler do
  let!(:user) { create(:user, prestige_level: 5, experience: 200) }
  let!(:neurobox_level_mission) { Missions::NeuroboxLevelMission.create(user: user, state: :running) }

  specify do
    described_class.call(user: user)

    expect(neurobox_level_mission.reload.state).to eq("failed")
  end
end
