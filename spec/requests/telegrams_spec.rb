require 'rails_helper'

RSpec.describe "Telegrams", type: :request do
  describe "POST /telegram" do
    before { stub_telegram }

    xit "throttles requests" do
      post '/telegram', params: build_telegram_request(text: '/start').to_h
      expect(response).to have_http_status(200)
      post '/telegram', params: build_telegram_request(text: '/start').to_h
      expect(response).to have_http_status(200)

      post '/telegram', params: build_telegram_callback_query(data: 'data').to_h.to_json
      expect(response).to have_http_status(202)
    end
  end
end
