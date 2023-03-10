# frozen_string_literal: true

class ContractsConfig < ApplicationConfig
  attr_config :manager_address, :manager_secret_key, :manager_public_key, :contracts_address, :manager_base64_address
end
