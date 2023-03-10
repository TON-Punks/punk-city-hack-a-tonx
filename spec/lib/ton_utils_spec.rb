# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TonUtils do
  describe 'hex_address' do
    let(:base64) { "EQAhJw_z5nTyvy0nKEd1g8B7BmrgHO6vq8qNrNG5Bcj4ApcH" }
    specify do
      expect(described_class.hex_address(base64)).to eq("0:21270ff3e674f2bf2d2728477583c07b066ae01ceeafabca8dacd1b905c8f802")
    end
  end
end
