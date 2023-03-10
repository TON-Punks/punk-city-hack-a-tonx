class BlackMarket::Purchases::Complete
  include Interactor

  AFTER_COMPLETE_MAPPING = {
    BlackMarketProduct::EMOJI_PACK => BlackMarket::Purchases::Callbacks::EmojiPack,
    BlackMarketProduct::NEUROPUNK => BlackMarket::Purchases::Callbacks::Neuropunk
  }

  delegate :purchase, to: :context

  def call
    purchase.update(state: :completed)

    AFTER_COMPLETE_MAPPING.fetch(purchase.black_market_product.slug, NilInteractor).call(purchase: purchase)
  end
end
