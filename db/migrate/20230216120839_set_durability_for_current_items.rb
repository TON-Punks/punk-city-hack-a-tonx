class SetDurabilityForCurrentItems < ActiveRecord::Migration[6.1]
  def change
    ItemsUser.where.not(item_id: Items::Weapon.default).find_each do |items_user|
      items_user.initialize_durability
      items_user.save!
    end
  end
end
