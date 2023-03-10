# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wallets::CreateCredentials do
  describe 'call' do
    specify do
      result = described_class.call

      expect(result.mnemonic).to be_present
      expect(result.secret_key).to be_present
      expect(result.public_key).to be_present
      expect(result.address).to be_present
      expect(result.base64_address).to be_present
      expect(result.base64_address_bounce).to be_present
    end
  end
end
