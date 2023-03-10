FactoryBot.define do
  factory :referral do
    user
    referred { create :user }
  end
end
