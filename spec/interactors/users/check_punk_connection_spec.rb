# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CheckPunkConnection do
  let(:punk_owner_address) { "0:3bb774f6f4802ab9dd3b100fcdf828f42d360d779775d1f4eb97d5c8b21fe794" }
  let(:wallet) do
    create :wallet,
      address: "0:21270ff3e674f2bf2d2728477583c07b066ae01ceeafabca8dacd1b905c8f802",
      base64_address_bounce: "EQAhJw_z5nTyvy0nKEd1g8B7BmrgHO6vq8qNrNG5Bcj4ApcH"
  end

  let(:punk) { create :punk, owner: punk_owner_address }
  let(:user) { wallet.user }
  before do
    create :punk_connection, user: wallet.user, punk: punk
    stub_telegram
  end

  around { |e| VCR.use_cassette("toncenter/account_transactions/#{wallet.address}", &e) }

  specify do
    described_class.call(user: user)
    expect(user.reload.punk).to eq(punk)
  end
end
