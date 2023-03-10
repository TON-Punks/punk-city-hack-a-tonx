# frozen_string_literal: true

class ToncenterConfig < ApplicationConfig
  attr_config :api_key, :url

  def json_rpc_url
    "#{url}jsonRPC"
  end
end
