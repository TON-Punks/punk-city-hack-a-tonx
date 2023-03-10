class Telegram::Callback::SecretEvent < Telegram::Callback
  def menu
    buttons = [
      [TelegramButton.new(text: I18n.t("secret_event.menu.buttons.sponsor"), data: "#secret_event##sponsor:")],
      [to_main_menu_button]
    ]

    total = PraxisTransaction.where(operation_type: PraxisTransaction::TONARCHY_SPONSORSHIP).sum(:quantity)
    sponsors_count = PraxisTransaction.where(operation_type: PraxisTransaction::TONARCHY_SPONSORSHIP).select(:user_id).distinct.count
    caption = I18n.t("secret_event.menu.caption", sponsors_count: sponsors_count, total: total)

    if message_to_update?
      update_inline_keyboard(photo: secret_event_photo, caption: caption, buttons: buttons)
    else
      send_photo_with_keyboard(photo: secret_event_photo, caption: caption, buttons: buttons)
    end
  end

  def sponsor
    buttons = [menu_button]

    text = I18n.t("secret_event.sponsor.caption")
    user.update!(next_step: "#secret_event##enter_amount:")

    if message_to_update?
      update_inline_keyboard(photo: sponsor_photo, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: sponsor_photo, caption: text, buttons: buttons)
    end
  end

  def enter_amount
    amount = telegram_request.message.text.strip.to_i

    return send_photo_with_keyboard(photo: sponsor_photo, caption: I18n.t("secret_event.sponsor.errors.invalid_number"), buttons: [menu_button]) if amount <= 0
    return send_photo_with_keyboard(photo: sponsor_photo, caption: I18n.t("secret_event.sponsor.errors.insufficient_funds"), buttons: [menu_button]) if user.praxis_balance < amount

    user.praxis_transactions.create!(operation_type: PraxisTransaction::TONARCHY_SPONSORSHIP, quantity: amount)
    user.update!(next_step: nil)

    success_message = I18n.t("secret_event.sponsor.success", amount: amount)
    send_photo_with_keyboard(caption: success_message, photo: secret_event_photo, buttons: [to_main_menu_button])
  end

  private

  def secret_event_photo
    image_for("menu.jpeg")
  end

  def sponsor_photo
    image_for("sponsor_with_praxis.jpeg")
  end

  def menu_button
    TelegramButton.new(text: I18n.t("common.menu"), data: "#secret_event##menu:")
  end

  def image_for(path)
    File.open(Rails.root.join("telegram_assets/images/secret_event/#{path}"))
  end
end
