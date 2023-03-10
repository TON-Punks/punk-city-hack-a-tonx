# frozen_string_literal: true

require "rails_helper"

RSpec.describe PunkConnections::Disconnect do
  let!(:user) { create(:user, prestige_level: 5, experience: 100, prestige_expirience: 50) }
  let(:punk) { create(:punk, prestige_level: 5, experience: 100, prestige_expirience: 50) }
  let(:punk_connection) { create(:punk_connection, user: user, punk: punk, connected_at: 2.days.ago) }

  specify do
    expect(Users::UpdateProfileWorker).to receive(:perform_in)
    expect(Missions::NeuroboxLevel::ResetHandler).to receive(:call).with(user: user)
    described_class.call(punk_connection: punk_connection)

    expect(user.punk).to be_blank
    expect(punk.experience).to eq(100)
    expect(punk.prestige_expirience).to eq(50)
    expect(punk.prestige_level).to eq(5)

    expect(user.experience).to eq(0)
    expect(user.prestige_expirience).to eq(0)
    expect(user.prestige_level).to eq(0)

    expect(punk_connection.connected_at).to be_nil
  end
end
