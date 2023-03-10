FactoryBot.define do
  factory :dao_proposal do
    punk
    name { "MyText" }
    description { "MyText" }
    state { :active }
  end
end
