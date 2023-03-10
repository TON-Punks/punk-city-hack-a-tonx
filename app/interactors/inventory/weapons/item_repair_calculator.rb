class Inventory::Weapons::ItemRepairCalculator
  include Interactor

  PRAXIS_PER_POINT = 60
  PRICE_INCREASE_MODIFIER = 0.2

  delegate :weapon_user, to: :context

  def call
    weapon_user.initialize_durability
    context.current_durability = weapon_user.current_durability
    context.max_durability = weapon_user.item.durability
    context.restored_durability = weapon_user.restored_durability
    context.multiplier = (PRICE_INCREASE_MODIFIER * context.restored_durability).round(2)
    context.point_price = (PRAXIS_PER_POINT + PRAXIS_PER_POINT * context.multiplier / 100).round
    context.praxis_price = ((context.max_durability - context.current_durability) * context.point_price).round
  end
end
