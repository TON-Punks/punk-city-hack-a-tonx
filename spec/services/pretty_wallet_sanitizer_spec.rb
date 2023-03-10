require 'rails_helper'

RSpec.describe PrettyWalletSanitizer do
  let(:wallet) { "ABC_XYZ_LL" }

  specify do
    expect(described_class.call(wallet)).to eq("ABC\\_XYZ\\_LL")
  end
end
