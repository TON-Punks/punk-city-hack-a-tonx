# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::External::StonfiAirdropsController do
  describe "#show" do
    context "when user not completed" do
      let(:user) { create(:user) }

      specify do
        get :show, params: { chat_id: user.chat_id }

        expect(JSON.parse(response.body)).to eq({ "completed" => false, "ton_battles_count" => 0 })
      end
    end

    context "when user creator participated" do
      let(:user) { create(:user) }

      before { create(:rock_paper_scissors_game, bet_currency: :ton, creator: user, state: :creator_won) }

      specify do
        get :show, params: { chat_id: user.chat_id }

        expect(JSON.parse(response.body)).to eq({ "completed" => true, "ton_battles_count" => 1 })
      end
    end

    context "when user opponent participated" do
      let(:user) { create(:user) }

      before { create(:rock_paper_scissors_game, bet_currency: :ton, opponent: user, state: :opponent_won) }

      specify do
        get :show, params: { chat_id: user.chat_id }

        expect(JSON.parse(response.body)).to eq({ "completed" => true, "ton_battles_count" => 1 })
      end
    end

    context "when user creator archived" do
      let(:user) { create(:user) }

      before { create(:rock_paper_scissors_game, bet_currency: :ton, creator: user, state: :archived) }

      specify do
        get :show, params: { chat_id: user.chat_id }

        expect(JSON.parse(response.body)).to eq({ "completed" => false, "ton_battles_count" => 0 })
      end
    end

    context "when user creator private game" do
      let(:user) { create(:user) }

      before { create(:rock_paper_scissors_game, bet_currency: :ton, creator: user, state: :creator_won, visibility: :private) }

      specify do
        get :show, params: { chat_id: user.chat_id }

        expect(JSON.parse(response.body)).to eq({ "completed" => false, "ton_battles_count" => 0 })
      end
    end
  end
end
