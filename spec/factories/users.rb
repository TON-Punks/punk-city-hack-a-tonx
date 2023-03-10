FactoryBot.define do
  factory :user do
    sequence(:chat_id) { |n| n }
    username { "MyString" }
    locale { "ru" }
    prestige_level { 1 }
    prestige_expirience { 100 }

    trait :bot do
      id { TelegramConfig.bot_ids.first }
    end

    trait :with_weapons do
      transient do
        weapons_rarity { :mythical }
      end

      after(:create) do |user, options|
        weapons = Lootboxes::SERIES_TO_CONTENT[:initial].
          select { |weapon| weapon[:data][:rarity] == options.weapons_rarity }.
          map { |item| Item.build_from_data(:weapon, item[:data]) }

        user.items = weapons
        user.items_users.each(&:equip!)
      end
    end

    trait :with_default_weapons do
      after(:create) do |user|
        weapons = Items::Weapons::DEFAULT.map { Item.build_from_data(:weapon, _1) }
        user.items = weapons
        user.items_users.each(&:equip!)
      end
    end

    trait :with_regular_weapons do
      with_weapons { { weapons_rarity: :regular } }
    end

    trait :with_rare_weapons do
      with_weapons { { weapons_rarity: :rare } }
    end

    trait :with_mythical_weapons do
      with_weapons { { weapons_rarity: :mythical } }
    end
  end
end
