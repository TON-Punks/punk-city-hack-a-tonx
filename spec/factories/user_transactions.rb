FactoryBot.define do
  factory :user_transaction do
    user_session { nil }
    total { "" }
    comission { "" }
    transaction_type { "MyString" }
  end
end
