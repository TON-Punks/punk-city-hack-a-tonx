FactoryBot.define do
  factory :wallet_credential do
    wallet { nil }
    public_key { "MyText" }
    secret_key { "MyText" }
    mnemonic { "MyText" }
  end
end
