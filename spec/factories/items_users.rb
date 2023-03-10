FactoryBot.define do
  factory :items_user, class: ItemsUser do
    item
    user
    data { {} }
  end
end
