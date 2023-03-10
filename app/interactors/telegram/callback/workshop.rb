class Telegram::Callback::Workshop < Telegram::Callback
  def menu
    buttons = weapons_mapping
    buttons << [back_button]

    text = I18n.t("workshop.menu.caption")

    send_or_update_inline_keyboard(photo: menu_photo, caption: text, buttons: buttons)
  end

  def repair
    weapon_name = callback_arguments["weapon"].to_sym
    item_user = equipped_weapon_item(weapon_name)
    return show_default_weapon_error if item_user.blank? || item_user.item.default?

    weapon = item_user.item
    calculator = repair_calculator(item_user)

    buttons = []

    if calculator.praxis_price.positive?
      buttons << [TelegramButton.new(text: I18n.t("workshop.repair.button"), data: "#workshop##repair_confirm:item_user_id=#{item_user.id}")]
    end

    buttons << [TelegramButton.new(text: I18n.t("common.back"), data: "#workshop##menu:")]

    text = I18n.t("workshop.repair.caption",
      weapon_name: I18n.t("workshop.custom_weapons.#{weapon_name}", name: I18n.t("weapons.names.#{weapon.name}")),
      current_durability: calculator.current_durability,
      max_durability: calculator.max_durability,
      restored_durability: calculator.restored_durability,
      multiplier: calculator.multiplier,
      point_price: calculator.point_price,
      total_price: calculator.praxis_price,
      user_balance: user.praxis_balance
    )

    photo = File.open(::Workshop::CreateRepairImage.call(item_user: item_user, repaired: false).output_path)

    send_or_update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
  end

  def repair_confirm
    item_user = user.items_users.find(callback_arguments["item_user_id"].to_i)

    if user.praxis_balance >= repair_calculator(item_user).praxis_price
      result = Inventory::Weapons::Repair.call(user: user, weapon_user_id: item_user.id)

      if result.success?
        show_repair_success(item_user)
      else
        show_insufficient_praxis_balance_error
      end
    else
      show_insufficient_praxis_balance_error
    end
  end

  private

  def menu_photo
    File.open(TelegramImage.path("workshop.png"))
  end

  def error_photo
    File.open(TelegramImage.path("workshop_error.png"))
  end

  def show_default_weapon_error
    buttons = [
      [cyber_arena_button],
      [inventory_button],
      [repair_weapon_button],
      [back_menu_button]
    ]

    text = I18n.t("workshop.errors.default_weapon")

    send_or_update_inline_keyboard(photo: error_photo, caption: text, buttons: buttons)
  end

  def cyber_arena_button
    TelegramButton.new(text: I18n.t("menu.cyber_arena"), data: "#cyber_arena##menu:")
  end

  def repair_weapon_button
    TelegramButton.new(text: I18n.t("residential_block.buttons.workshop"), data: "#workshop##menu:")
  end

  def inventory_button
    TelegramButton.new(text: I18n.t("residential_block.buttons.inventory"), web_app: { url: "#{IntegrationsConfig.frontend_url}?token=#{user.auth_token}" })
  end

  def show_insufficient_praxis_balance_error
    buttons = [
      [cyber_arena_button],
      [bank_button],
      [back_menu_button]
    ]

    text = I18n.t("workshop.errors.insufficient_praxis_balance")

    send_or_update_inline_keyboard(photo: error_photo, caption: text, buttons: buttons)
  end

  def show_repair_success(item_user)
    weapon_name = RockPaperScissorsGame::MOVE_TO_NAME[item_user.item.position]
    calculator = repair_calculator(item_user)
    weapon = item_user.item

    buttons = [
      [cyber_arena_button],
      [repair_weapon_button],
      [back_menu_button]
    ]

    text = I18n.t("workshop.repair_confirm.caption",
      weapon_name: I18n.t("workshop.custom_weapons.#{weapon_name}", name: I18n.t("weapons.names.#{weapon.name}")),
      current_durability: calculator.current_durability,
      multiplier: calculator.multiplier
    )

    photo = File.open(::Workshop::CreateRepairImage.call(item_user: item_user, repaired: true).output_path)

    send_or_update_inline_keyboard(photo: photo, caption: text, buttons: buttons)
  end

  def repair_calculator(item_user)
    Inventory::Weapons::ItemRepairCalculator.call(weapon_user: item_user.reload)
  end

  def weapons_mapping
    [
      [button_for_weapon(:katana)],
      [button_for_weapon(:hack)],
      [button_for_weapon(:grenade)],
      [button_for_weapon(:pistol)],
      [button_for_weapon(:annihilation)],
    ]
  end

  def button_for_weapon(name)
    TelegramButton.new(text: I18n.t("workshop.weapons.#{name}"), data: "#workshop##repair:weapon=#{name}")
  end

  def equipped_weapon_item(name)
    position = RockPaperScissorsGame::NAME_TO_MOVE[name]
    user.items_users.joins(:item).where("items_users.data->>'equipped' = 'true'").where("items.data->>'position' = '?'", position).first
  end

  def bank_button
    TelegramButton.new(text: I18n.t("wallet.buttons.bank"), data: "#bank##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#residential_block##menu:")
  end

  def back_menu_button
    TelegramButton.new(text: I18n.t("common.menu"), data: "#menu##menu:")
  end
end
