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
class Item < ApplicationRecord
  TYPES_MAPPING = {
    weapon: Items::Weapon,
    experience: Items::Experience,
    praxis: Items::Praxis
  }

  has_many :items_users, dependent: :destroy
  has_many :users, through: :items_users

  scope :weapons, -> { where(type: Items::Weapon.name) }

  def self.build_from_data(item_type, data)
    item_klass = TYPES_MAPPING.fetch(item_type.to_sym)
    name = data[:name]

    item_klass.find_by(name: name) || item_klass.new(name: name, data: data.slice(:position, :stats, :image_url, :rarity))
  end
end
