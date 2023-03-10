module Lootboxes
  SERIES_TO_CONTENT = {
    initial: [
      { type: :weapon, data: { rarity: :regular, name: 'portable_reactor', position: 1, stats: { min_damage: 14, max_damage: 18, durability: 20 }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/annihilation-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'particle_splitter', position: 1, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { critical: 0.25 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/annihilation-rare.png'  } },
      { type: :weapon, data: { rarity: :mythical, name: 'dirty_bomb', position: 1, stats: { min_damage: 11, max_damage: 15, durability: 60, perks: { poison: [0.3, 3] } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/annihilation-mythical.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'hardened_steel', position: 2, stats: { min_damage: 11, max_damage: 15, durability: 20, perks: { health: 5 }}, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/katana-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'static_charge', position: 2, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { faraday: 0.4 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/katana-rare.png'  } },
      { type: :weapon, data: { rarity: :mythical, name: 'samurai_spirit', position: 2, stats: { min_damage: 11, max_damage: 15, durability: 60, perks: { force_field: [0.35, 3] } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/katana-mythical.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'bruteforce_attack', position: 3, stats: { min_damage: 11, max_damage: 15, durability: 20, perks: { health: 5 }}, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/hack-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'injector', position: 3, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { paracelsus: [0.25, 3] } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/hack-rare.png'  } },
      { type: :weapon, data: { rarity: :mythical, name: 'matrix', position: 3, stats: { min_damage: 11, max_damage: 15, durability: 60, perks: { system_reset: 0.4 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/hack-mythical.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'sticky_bomb', position: 4, stats: { min_damage: 17, max_damage: 17, durability: 20 }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/grenade-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'cluster_projectile', position: 4, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { contusion: 0.35 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/grenade-rare.png'  } },
      { type: :weapon, data: { rarity: :mythical, name: 'destroyer', position: 4, stats: { min_damage: 11, max_damage: 15, durability: 60, perks: { breaker: 0.2 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/grenade-mythical.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'model_94', position: 5, stats: { min_damage: 14, max_damage: 18, durability: 20 }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/pistol-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'supernova', position: 5, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { blinding_light: 0.4 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/pistol-rare.png'  } },
      { type: :weapon, data: { rarity: :mythical, name: 'amphibian', position: 5, stats: { min_damage: 11, max_damage: 15, durability: 60, perks: { onearmed_bandit: 0.3 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/pistol-mythical.png'  } },
    ],
    lite: [
      { type: :weapon, data: { rarity: :regular, name: 'portable_reactor', position: 1, stats: { min_damage: 14, max_damage: 18, durability: 20 }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/annihilation-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'particle_splitter', position: 1, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { critical: 0.25 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/annihilation-rare.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'hardened_steel', position: 2, stats: { min_damage: 11, max_damage: 15, durability: 20, perks: { health: 5 }}, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/katana-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'static_charge', position: 2, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { faraday: 0.4 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/katana-rare.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'bruteforce_attack', position: 3, stats: { min_damage: 11, max_damage: 15, durability: 20, perks: { health: 5 }}, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/hack-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'injector', position: 3, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { paracelsus: [0.25, 3] } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/hack-rare.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'sticky_bomb', position: 4, stats: { min_damage: 17, max_damage: 17, durability: 20 }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/grenade-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'cluster_projectile', position: 4, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { contusion: 0.35 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/grenade-rare.png'  } },

      { type: :weapon, data: { rarity: :regular, name: 'model_94', position: 5, stats: { min_damage: 14, max_damage: 18, durability: 20 }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/pistol-regular.png'  } },
      { type: :weapon, data: { rarity: :rare, name: 'supernova', position: 5, stats: { min_damage: 11, max_damage: 15, durability: 40, perks: { blinding_light: 0.4 } }, image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/initial/pistol-rare.png'  } },

      { type: :experience, data: { name: 'experience', image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/lite/experience.png' } },
      { type: :praxis, data: { name: 'praxis', image_url: 'https://punk-metaverse.fra1.digitaloceanspaces.com/lootboxes/lite/praxis.png' } },
    ]
  }
end
