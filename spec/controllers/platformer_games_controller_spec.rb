# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlatformerGamesController do
  let(:user) { create :user }

  describe '#create' do
    specify do
      expect { post :create, params: { chat_id: user.chat_id }  }.to change { user.platformer_games.count }.by(1)

      expect(response).to be_successful
    end
  end

  describe '#update' do
    before do
      create :platformer_statistic, user: create(:user), top_score: 100
    end

    let(:game) { create :platformer_game, user: user }

    specify do
      skip
      expect(Telegram::Notifications::NewToadzExperience).to receive(:call).with(user: user, exp: 2)
      expect(TelegramApi).to receive(:send_message).twice

      expect {
        put :update, params: { id: game.id, score: 220 }
      }.to change { user.reload.experience }.by(2)

      expect(response).to be_successful
      expect(game.reload.score).to eq(220)
    end

    context 'already updated' do
      before { game.update(score: 5) }

      specify do
        skip
        expect(Telegram::Notifications::NewToadzExperience).not_to receive(:call)

        put :update, params: { id: game.id, score: 10 }

        expect(response.status).to eq(422)
      end
    end
  end
end
