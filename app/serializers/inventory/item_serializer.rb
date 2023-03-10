class Inventory::ItemSerializer < ApplicationSerializer
  identifier :id

  field :name do |item|
    I18n.t("weapons.names.#{item.name}")
  end

  field :data do |item|
    attributes = item.data.slice('position', 'image_url', 'rarity', 'stats')
    if item.perks.blank?
      attributes
    else
      perk_name, extra_data = item.perks.first
      chance, rounds = extra_data
      attributes.merge(extra_description: I18n.t("weapons.perks.#{perk_name}", chance: (chance * 100).to_i, rounds: rounds))
    end
  end
end
