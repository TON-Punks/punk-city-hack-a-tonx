FactoryBot.define do
  factory :praxis_transaction do
    user
    operation_type { 2 }
    quantity { 100 }
  end
end
