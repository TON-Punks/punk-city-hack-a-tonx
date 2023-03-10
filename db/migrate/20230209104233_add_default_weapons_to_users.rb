class AddDefaultWeaponsToUsers < ActiveRecord::Migration[6.1]
  def change
    Items::Weapon.destroy_all
    weapons = Items::Weapons::DEFAULT.map { Item.build_from_data(:weapon, _1) }

    User.find_each do |user|
      user.items = weapons
      user.items_users.each(&:equip!)
    end
  end
end
