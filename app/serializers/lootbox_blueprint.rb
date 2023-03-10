class LootboxBlueprint < Blueprinter::Base
  identifier :id

  fields :state, :series

  field :content do |lootbox|
    Lootboxes::SERIES_TO_CONTENT[lootbox.series.to_sym].map do |item|
      if item[:type].to_s == "weapon"
        serialize_weapon(item)
      else
        serialize_item(item)
      end
    end
  end

  field :result do |lootbox|
    if lootbox.done?
      item = lootbox.result&.deep_symbolize_keys
      if item
        if item[:type].to_s == "weapon"
          serialize_weapon(item)
        else
          serialize_item(item)
        end
      end
    end
  end

  def self.serialize_item(item)
    {
      type: item[:type],
      name: I18n.t("items.names.#{item[:data][:name]}"),
      image_url: item[:data][:image_url]
    }
  end

  def self.serialize_weapon(item)
    perk_name, extra_data = item.dig(:data, :stats, :perks).to_h.first
    chance, rounds = extra_data

    fields = {
      I18n.t('lootboxes.fields.rarity') => item[:data][:rarity],
      I18n.t('lootboxes.fields.durability') => item.dig(:data, :stats, :durability)
    }

    perk_description = if perk_name
      I18n.t("weapons.perks.#{perk_name}", chance: (chance * 100).to_i, rounds: rounds)
    else
      I18n.t!("weapons.descriptions.#{item[:data][:name]}") rescue nil
    end

    fields.merge!(I18n.t('lootboxes.fields.description') => perk_description) if perk_description

    {
      type: item[:type],
      name: I18n.t("weapons.names.#{item[:data][:name]}"),
      image_url: item[:data][:image_url],
      fields: fields
    }
  end
end
