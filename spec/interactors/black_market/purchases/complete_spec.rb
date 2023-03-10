require 'rails_helper'

RSpec.describe BlackMarket::Purchases::Complete do
  subject { described_class.call(purchase: purchase) }

  let(:purchase) { create(:black_market_purchase, black_market_product: product) }
  let(:product) { create(:black_market_product, slug: BlackMarketProduct::EMOJI_PACK) }

  specify do
    expect(BlackMarket::Purchases::Callbacks::EmojiPack).to receive(:call).with(purchase: purchase)
    subject
    expect(purchase).to be_completed
  end
end
