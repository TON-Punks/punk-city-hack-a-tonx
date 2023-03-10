# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Inventory::WeaponsController do
  include_examples "web app authenticated"

  describe "#equip" do
    let(:weapon) { create(:weapon_item, data: weapon_data) }
    let!(:items_user) { create(:items_user, item: weapon, user: user, data: item_user_data) }

    let(:weapon_data) do
      {
        damage: 10
      }
    end
    let(:item_user_data) do
      {
        equipped: false
      }
    end

    specify do
      post :equip, params: { id: items_user.id }

      expect(items_user.reload.data["equipped"]).to be_truthy
    end
  end

  describe "#unequip" do
    let(:weapon) { create(:weapon_item, data: weapon_data) }
    let!(:items_user) { create(:items_user, item: weapon, user: user, data: item_user_data) }

    let(:weapon_data) do
      {
        damage: 10
      }
    end
    let(:item_user_data) do
      {
        equipped: true
      }
    end

    specify do
      post :unequip, params: { id: items_user.id }

      expect(items_user.reload.data["equipped"]).to be_falsey
    end
  end
end
