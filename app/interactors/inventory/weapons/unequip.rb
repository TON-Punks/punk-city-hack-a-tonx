class Inventory::Weapons::Unequip
  include Interactor

  delegate :weapon_user_id, :user, to: :context

  def call
    weapon_user = user.items_users.find_by(id: weapon_user_id)
    context.fail!(error_message: "User does not have this weapon") if weapon_user.blank?
    context.fail!(error_message: "Default weapon can't be unequipped") if weapon_user.item.rarity == 'default'

    ItemsUser.transaction do
      weapon_user.unequip!
      position = weapon_user.item.position
      user.items_users.joins(:item).merge(Items::Weapon.for_position(position).with_rarity(:default)).first&.equip!
    end

    Users::UpdateWeaponsImageWorker.perform_async(user.id)
  end
end
