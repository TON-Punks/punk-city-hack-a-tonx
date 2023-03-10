FactoryBot.define do
  factory :withdraw_request do
    address { '0:eec8e3c0f8b8c87164b9dd2397913716be6f57f84c1255a0db0ff053218a8830' }
    amount { 1232 }
    wallet
  end
end
