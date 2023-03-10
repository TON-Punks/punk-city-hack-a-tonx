class Inventory::Weapons::Repair
  include Interactor

  delegate :weapon_user_id, :user, to: :context

  def call
    weapon_user = user.items_users.find_by(id: weapon_user_id)
    context.fail!(error_message: "User does not have this weapon") if weapon_user.blank?

    result = Inventory::Weapons::ItemRepairCalculator.call(weapon_user: weapon_user)
    return if result.praxis_price.zero?

    ApplicationRecord.transaction do
      user.praxis_transactions.weapon_repaired.create!(quantity: result.praxis_price)
      context.fail!(error_message: "Invalid praxis_balance") unless user.praxis_balance_valid?

      weapon_user.restored_durability += result.max_durability - result.current_durability
      weapon_user.current_durability = result.max_durability
    end
  end
end
