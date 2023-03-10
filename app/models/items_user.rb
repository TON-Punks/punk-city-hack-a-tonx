# == Schema Information
#
# Table name: items_users
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_items_users_on_item_id  (item_id)
#  index_items_users_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (user_id => users.id)
#
class ItemsUser < ApplicationRecord
  WEAPON_ATTRIBUTES = %w[current_durability restored_durability]

  after_create do |item_user|
    result = Inventory::CollectItem.call(item_user: item_user)
    update(data: { quantity: result.quantity }) if result.success?
  end

  belongs_to :user
  belongs_to :item

  scope :equipped, -> { where("items_users.data->>'equipped' = 'true'") }
  scope :not_disabled, -> { where("(items_users.data->>'disabled') is null") }

  def initialize_durability
    self.current_durability ||= item.durability
    self.restored_durability ||= 0
  end

  WEAPON_ATTRIBUTES.each do |attribute|
    define_method attribute do
      self.data[attribute]
    end

    define_method "#{attribute}=" do |value|
      self.data[attribute] = value
      self.save!
    end
  end

  def equip!
    data["equipped"] = true
    save!
  end

  def unequip!
    data["equipped"] = false
    save!
  end

  def disable!
    data["disabled"] = false
    save!
  end
end
