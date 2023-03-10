# == Schema Information
#
# Table name: items
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  name       :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_items_on_name  (name) UNIQUE
#
class Items::Weapon < Item
  STATS_ATTRIBUTES = %w[perks min_damage max_damage durability]
  DATA_ATTRIBUTES = %w[position image_url rarity]

  scope :for_position, -> position { where("items.data->>'position' = '?'", position) }
  scope :with_rarity, -> rarity { where("items.data->>'rarity' = ?", rarity) }
  scope :default, -> { with_rarity(:default) }

  STATS_ATTRIBUTES.each do |attribute|
    define_method attribute do
      self.data['stats'][attribute]
    end
  end

  DATA_ATTRIBUTES.each do |attribute|
    define_method attribute do
      self.data[attribute]
    end
  end

  def collectable?
    false
  end

  def default?
    rarity == 'default'
  end
end
