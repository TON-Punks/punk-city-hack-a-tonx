class BlackMarket::ProductPriceDecreaseWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform
    BlackMarketProduct.find_each { |product| BlackMarket::ProductPriceDecreaser.call(product) }
  end
end
