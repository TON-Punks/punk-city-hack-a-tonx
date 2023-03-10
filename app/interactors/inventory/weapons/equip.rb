class Inventory::Weapons::Equip
  include Interactor

  delegate :weapon_user_id, :user, to: :context

  def call
    weapon_user = user.items_users.find_by(id: weapon_user_id)
    context.fail!(error_message: "User does not have this weapon") if weapon_user.blank?

    position = weapon_user.item.position

    ItemsUser.transaction do
      user.items_users.equipped.joins(:item).merge(Items::Weapon.for_position(position)).first&.unequip!
      weapon_user.equip!
    end

    Users::UpdateWeaponsImageWorker.perform_async(user.id)
  end
end
