class RockPaperScissorsGames::DecreaseWeaponsDurability
  include Interactor

  delegate :game, to: :context

  def call
    ids = game.cached_items_users.values.flatten.map(&:id)
    items_user = ItemsUser.includes(:user, :item).joins(:item)
      .where.not(items: { id: Items::Weapon.default }).where(id: ids)

    messages = items_user.each_with_object({ game.creator_id => '', game.opponent_id => '' }) do |items_user, memo|
      items_user.initialize_durability
      durability = items_user.current_durability

      if durability > 1
        notification_key = "notifications.decreased_durability.decreased"
        items_user.current_durability -= 1
        items_user.save!
      else
        notification_key = "notifications.decreased_durability.disabled"
        items_user.current_durability = 0
        items_user.disable!
        Inventory::Weapons::Unequip.call(weapon_user_id: items_user.id, user: items_user.user)
      end

      message = I18n.t(notification_key,
        name: I18n.t("weapons.names.#{items_user.item.name}"),
        current_durability: items_user.current_durability,
        total_durability: items_user.item.durability
      )

      memo[items_user.user_id] << "#{message}\n"
    end

    TelegramApi.send_message(chat_id: game.creator.chat_id, text: messages[game.creator_id]) if messages[game.creator_id].present?
    TelegramApi.send_message(chat_id: game.opponent.chat_id, text: messages[game.opponent_id]) if messages[game.opponent_id].present?
  end
end
