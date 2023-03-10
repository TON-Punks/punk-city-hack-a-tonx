# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GameRoundsController do
  let(:user) { create :user, :with_weapons }
  let(:game) { create :rock_paper_scissors_game, creator: user, opponent: user }

  before do
    game.cache_weapons
  end

  describe '#index' do
    before do
      create_list :game_round, 2, winner: :creator, rock_paper_scissors_game: game, opponent_damage: 10, creator_damage: 10
    end

    specify do
      get :index, { params: { rock_paper_scissors_game_id: game.id, token: user.auth_token }}

      expect(JSON.parse(response.body)['game_rounds'].count).to eq(2)
    end
  end

  describe '#creator' do
    specify do
      post :create, { params: { rock_paper_scissors_game_id: game.id, token: user.auth_token, move: :katana }}

      json = JSON.parse(response.body)
      expect(json['game_round']['creator_weapon']).to be_present
      expect(json['game_round']['opponent_weapon']).to be_blank
    end
  end
end
