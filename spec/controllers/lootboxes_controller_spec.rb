# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LootboxesController do
  let(:black_market_purchase) { create :black_market_purchase, user: user, black_market_product: product }
  let(:second_black_market_purchase) { create :black_market_purchase, user: user, black_market_product: product }
  let!(:lootbox) { create :lootbox, black_market_purchase: black_market_purchase, prepaid: true }
  let!(:second_lootbox) { create :lootbox, series: :lite, black_market_purchase: second_black_market_purchase, prepaid: false }
  let(:user) { create(:user) }
  let(:product) { BlackMarketProduct.fetch(BlackMarketProduct::AIRDROPPED_LOOTBOX) }

  describe '#index' do
    specify do
      get :index, params: { token: user.auth_token }

      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe '#show' do
    let(:lootbox) do
      create :lootbox, black_market_purchase: black_market_purchase, prepaid: true, state: :created, result: Lootboxes::SERIES_TO_CONTENT[:initial].sample
    end

    specify do
      get :show, params: { token: user.auth_token, id: lootbox.id }

      json = JSON.parse(response.body)
      expect(json['id']).to eq(lootbox.id)

      expect(json['content'].size).to eq(15)
      expect(json['result']).to be_blank
    end

    context 'after oppening' do
      before do
        stub_telegram
        Lootboxes::Open.call(lootbox: lootbox)
      end

      specify do
        get :show, params: { token: user.auth_token, id: lootbox.id }

        json = JSON.parse(response.body)
        expect(json['result']).to be_present
      end
    end
  end

  describe '#open' do
    specify do
      post :open, params: { token: user.auth_token, id: lootbox.id }

      expect(response).to be_successful
    end

    context 'when not prepaid' do
      before do
        lootbox.update(prepaid: false)
        create :wallet, user: lootbox.user
      end

      specify do
        post :open, params: { token: user.auth_token, id: lootbox.id }

        expect(response.status).to eq(422)
      end
    end
  end
end
