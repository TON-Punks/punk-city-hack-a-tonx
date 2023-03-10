# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TonPriceConverter do
  describe '#convert_to_usd' do
    let(:ton) { '10' }
    subject(:converter) { described_class.new(ton) }

    context 'when called the first time' do
      specify do
        VCR.use_cassette 'coinmarket/cryptocurrency_listings' do
          usd = converter.convert_to_usd
          expect(usd.to_s).to eq('18.33')
        end
      end
    end

    context 'when called the first time' do
      it 'uses cache' do
        VCR.use_cassette('coinmarket/cryptocurrency_listings') { converter.convert_to_usd }

        expect(converter.convert_to_usd.to_s).to eq('18.33')
      end
    end
  end
end
