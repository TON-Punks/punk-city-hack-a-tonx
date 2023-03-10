# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ProfilesController do
  describe "#show" do
    include_examples "web app authenticated"

    let(:expected_response) do
      {
        "profile" => {
          "id" => user.id,
          "identification" => user.identification,
          "level" => user.prestige_level,
          "experience" => user.prestige_expirience,
          "new_level_threshold" => 400,
          "ton_balance" => "11.23",
          "praxis_balance" => 0,
          "profile_url" => nil
        }
      }
    end

    before do
      create(:wallet, user: user, virtual_balance: 1_123_4567_000)
    end

    specify do
      get :show

      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end
end
