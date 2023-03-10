# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZeyaGamesController do
  let(:user) { create :user }

  describe '#create' do
    specify do
      expect { post :create, params: { chat_id: user.chat_id }  }.to change { user.zeya_games.count }.by(1)

      expect(response).to be_successful
    end
  end

  describe '#update' do
    before { skip }
    let(:game) { create :zeya_game, user: user }

    specify do
      expect(Telegram::Notifications::NewZeyaExperience).to receive(:call)
      put :update, params: { id: game.id, score: 220 }

      expect(response).to be_successful
      expect(game.reload.score).to eq(220)
    end

    context 'already updated' do
      before { game.update(score: 5) }

      specify do
        put :update, params: { id: game.id, score: 10 }

        expect(response.status).to eq(422)
      end
    end
  end
end
