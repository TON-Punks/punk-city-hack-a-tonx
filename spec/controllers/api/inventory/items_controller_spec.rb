# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Inventory::ItemsController do
  include_examples "web app authenticated"

  describe "#index" do
    let(:expected_response) do
      {
        "items" => [
          {
          "id"=> items_user.id,
          "data" => {
            "equipped" => false
          },
          "item"=>{
            "id"=>items_user.item.id,
            "name" => "Амфибия",
            "data" => {
              "extra_description" => "Однорукий бандит - на следующем ходу противник не может сходить Катаной, Пистолетом, Гранатой - 30%",
              "image_url" => "https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/pistol-mythical.png",
              "position" => 5,
              "rarity" => "mythical",
              "stats" => {
                "durability" => 60, "max_damage" => 15, "min_damage" => 11, "perks" => {  "onearmed_bandit" => 0.3 }
              }
            }
          }
        }]
      }
    end

    let(:weapon) do
      Item.build_from_data(:weapon, Lootboxes::SERIES_TO_CONTENT[:initial].last[:data])
    end
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
    let(:json_response) { JSON.parse(response.body) }

    specify do
      get :index

      expect(json_response).to eq(expected_response)
    end
  end
end
