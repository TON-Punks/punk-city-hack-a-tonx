# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RockPaperScissorsGamesController do
  let(:game) { create :rock_paper_scissors_game }
  let(:user) { game.creator }

  describe '#show' do
    specify do
      get :show, params: { id: game.id, token: user.auth_token }

      json = JSON.parse(response.body)['rock_paper_scissors_game']
      expect(json['id']).to eq(game.id)
      expect(json['creator']).to be_present
      expect(json['opponent']).to be_blank
    end

    context 'with opponent' do
      let(:game) { create :rock_paper_scissors_game, :with_opponent }

      specify do
        get :show, params: { id: game.id, token: user.auth_token }

        json = JSON.parse(response.body)['rock_paper_scissors_game']
        expect(json['id']).to eq(game.id)
        expect(json['opponent']).to be_present
      end
    end
  end

  describe '#destroy' do
    context 'when created' do
      specify do
        delete :destroy, params: { id: game.id, token: user.auth_token }

        expect(response.status).to eq(204)
      end
    end

    context 'when started' do
      let(:game) { create :rock_paper_scissors_game, :started }

      specify do
        delete :destroy, params: { id: game.id, token: user.auth_token }

        expect(response.status).to eq(422)
      end
    end
  end
end
