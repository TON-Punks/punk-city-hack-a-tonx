# frozen_string_literal: true

require "rails_helper"

RSpec.describe PunkConnections::Connect do
  let!(:user) { create(:user, prestige_level: 5, experience: 200) }
  let(:punk) { create(:punk, prestige_level: 13, experience: 100) }
  let(:punk_connection) { create :punk_connection, user: user, punk: punk }

  specify do
    expect(Users::UpdateProfileWorker).to receive(:perform_in)
    expect(Missions::NeuroboxLevel::ResetHandler).to receive(:call).with(user: user)
    described_class.call(punk_connection: punk_connection)

    expect(user.punk).to eq(punk)
    expect(user.punk.experience).to eq(200)
    expect(user.punk.prestige_level).to eq(13)
    expect(punk_connection.connected_at).to be_present
  end

  context "when punk already has punk" do
    let(:previous_owner) { create :user }
    before { create :punk_connection, punk: punk, user: previous_owner, state: :connected }

    specify do
      expect do
        described_class.call(punk_connection: punk_connection)
      end.to change { punk.reload.user }.from(previous_owner).to(user)
    end
  end

  context "when user has more prestige experience but prestige_level is smaller" do
    before { punk.update(prestige_level: 10, experience: 1) }

    specify do
      described_class.call(punk_connection: punk_connection)

      expect(user.punk).to eq(punk)
      expect(user.punk.experience).to eq(200)
      expect(user.punk.prestige_level).to eq(10)
      expect(punk_connection.connected_at).to be_present
    end
  end
end
