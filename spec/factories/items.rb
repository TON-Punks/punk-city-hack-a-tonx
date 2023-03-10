FactoryBot.define do
  factory :item, class: Item do
    name { "uniq" }
    data { {} }
  end

  factory :weapon_item, parent: :item, class: Items::Weapon
  factory :praxis_item, parent: :item, class: Items::Praxis
  factory :experience_item, parent: :item, class: Items::Experience
end
