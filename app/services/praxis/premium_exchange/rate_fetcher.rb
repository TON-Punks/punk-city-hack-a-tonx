class Praxis::PremiumExchange::RateFetcher
  SMALL = :small
  MEDIUM = :medium
  WHALE = :whale

  RATES = {
    SMALL => Praxis::PremiumExchangeRate.new(exp: 1000, praxis: 150, ton_fee: 0.49),
    MEDIUM => Praxis::PremiumExchangeRate.new(exp: 3000, praxis: 500, ton_fee: 1.49),
    WHALE => Praxis::PremiumExchangeRate.new(exp: 5000, praxis: 950, ton_fee: 2.49)
  }
end
