FactoryBot.define do
  factory :wallet do
    user
    address { "0:80a9cc37a248b937dc77868cb7c8587d1f9829a87c8c91a188b8257fb414f6ef" }
    balance { 0 }
    virtual_balance { 0 }
    base64_address { "UQCAqcw3oki5N9x3hoy3yFh9H5gpqHyMkaGIuCV_tBT271C3" }
    base64_address_bounce { "UQCAqcw3oki5N9x3hoy3yFh9H5gpqHyMkaGIuCV_tBT271C3" }

    trait :with_credential do
      after(:create) { |w| create :wallet_credential, wallet: w }
    end
  end
end
