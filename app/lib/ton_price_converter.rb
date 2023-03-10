class TonPriceConverter
  include RedisHelper
  include HTTParty

  API_KEY = '3aac14b4-3e03-417c-b614-b034bc2a463d'
  CACHE_KEY = 'marketcap-ton-price'
  CACHE_TTL = 6.hours.to_i

  attr_reader :ton

  def initialize(ton)
    @ton = BigDecimal(ton)
  end

  def convert_to_usd(precision: 2)
    usd = BigDecimal(price.to_s) * BigDecimal(ton)
    usd.round(precision)
  end

  private

  def price
    return cached_price if cached_price

    new_price = fetch_price
    save_price(new_price)
    new_price
  end

  def cached_price
    @cached_price ||= redis.get(CACHE_KEY)
  end

  def save_price(price)
    redis.setex(CACHE_KEY, CACHE_TTL, price)
  end

  def fetch_price
    response = self.class.get("https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?CMC_PRO_API_KEY=#{API_KEY}")
    response.parsed_response['data'].detect { |coin| coin['symbol'] == 'TON' }['quote']['USD']['price']
  end
end
