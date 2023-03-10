module Items::Weapons
  DEFAULT = [
    { rarity: :default, name: :annihilation, position: 1, stats: { min_damage: 11, max_damage: 15, perks: { critical: 0.15 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/annihilation-default.png' },
    { rarity: :default, name: :katana, position: 2, stats: { min_damage: 11, max_damage: 15, perks: { miss: 0.3 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/katana-default.png' },
    { rarity: :default, name: :hack, position: 3, stats: { min_damage: 11, max_damage: 15, perks: { vampirism: 0.3 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/hack-default.png' },
    { rarity: :default, name: :grenade, position: 4, stats: { min_damage: 14, max_damage: 19 }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/grenade-default.png' },
    { rarity: :default, name: :pistol, position: 5, stats: { min_damage: 11, max_damage: 15, perks: { counter: 0.1 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/pistol-default.png'}
  ]
end
