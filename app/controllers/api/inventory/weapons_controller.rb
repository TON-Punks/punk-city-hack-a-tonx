class Api::Inventory::WeaponsController < Api::BaseController
  def equip
    respond_with_result(
      Inventory::Weapons::Equip.call(user: current_user, weapon_user_id: params[:id])
    )
  end

  def unequip
    respond_with_result(
      Inventory::Weapons::Unequip.call(user: current_user, weapon_user_id: params[:id])
    )
  end
end
