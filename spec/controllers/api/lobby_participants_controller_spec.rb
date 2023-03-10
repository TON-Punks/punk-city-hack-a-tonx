# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::LobbyParticipantsController do
  let(:user) { create :user }

  describe '#index' do
    before { create_list :user, 4 }

    specify do
      get :index, params: { token: user.auth_token }

      participants = JSON.parse(response.body)['lobby_participants']
      expect(participants.size).to eq(5)
    end
  end


  describe '#create' do
    specify do
      post :create, params: { token: user.auth_token }

      expect(response.status).to eq(200)
    end
  end

  describe '#destroy' do
    specify do
      delete :destroy, params: { token: user.auth_token }

      expect(response.status).to eq(204)
    end
  end
end
