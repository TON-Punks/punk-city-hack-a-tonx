class Praxis::TonExchange::RateFetcher
  SMALL = :small
  MEDIUM = :medium
  WHALE = :whale

  RATES = {
    SMALL => Praxis::TonExchangeRate.new(ton: 10.0, praxis: 400),
    MEDIUM => Praxis::TonExchangeRate.new(ton: 20.0, praxis: 1200),
    WHALE => Praxis::TonExchangeRate.new(ton: 25.0, praxis: 1999)
  }
end
