# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TonConnect do
  let(:user) { create :user }

  specify do
    connect = described_class.new(user)

    expect(connect.url).to be_present
    expect(connect.public_key).to be_present
    expect(connect.secret_key).to be_present
    expect(connect.client_id).to be_present

    expect(connect.url).to include(connect.client_id)
  end
end
