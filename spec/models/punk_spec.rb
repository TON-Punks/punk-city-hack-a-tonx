require 'rails_helper'

RSpec.describe Punk, type: :model do
  describe 'punk_connetions' do
    let!(:user) { create :user }
    let!(:punk) { create :punk }
    let!(:punk_connections) { create_list :punk_connection, 2, user: user, punk: punk }

    specify do
      expect(punk.user).to be_blank
      expect(punk.punk_connections.size).to eq(2)

      punk_connections.first.connected!
      expect(punk.reload.user).to eq(user)


      punk.connected_punk_connection.disconnected!
      expect(punk.reload.user).to be_blank
    end
  end
end
