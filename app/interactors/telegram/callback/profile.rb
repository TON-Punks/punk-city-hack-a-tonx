class Telegram::Callback::Profile < Telegram::Callback
  delegate :wallet, to: :user

  def menu
    buttons = [
      [TelegramButton.new(text: I18n.t("profile.buttons.invite"), data: "#invite##menu:")]
    ]

    buttons << if user.punk.blank?
                 [TelegramButton.new(text: I18n.t("profile.buttons.connect_punk"), data: "#profile##connect_punk:")]
               else
                 [TelegramButton.new(text: I18n.t("profile.buttons.disconnect_punk"),
                   data: "#profile##disconnect_punk:")]
               end

    buttons << [language_button, notifications_button]

    actor = user.punk || user

    text = I18n.t("profile.labels.menu",
      games_total: user.rock_paper_scissors_games_total,
      games_wins: user.rock_paper_scissors_games_wins,
      games_losses: user.rock_paper_scissors_games_losses,
      prestige_level: actor.prestige_level,
      prestige_experience: actor.prestige_expirience,
      new_prestige_level_threshold: user.new_prestige_level_threshold(actor.prestige_level),
      ton_won: user.rock_paper_scissors_statistic.pretty_ton_won,
      ton_lost: user.rock_paper_scissors_statistic.pretty_ton_lost,
      praxis_won: user.rock_paper_scissors_statistic.praxis_won,
      praxis_lost: user.rock_paper_scissors_statistic.praxis_lost)

    buttons << [to_main_menu_button]

    if message_to_update?
      update_inline_keyboard(photo: default_profile, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: default_profile, text: text, buttons: buttons)
    end
  end

  def connect_punk(text = I18n.t("profile.labels.connect_punk"))
    punk_connection = user.punk_connections.requested.first
    return wait_for_transaction(punk_connection) if punk_connection.present?

    user.update!(next_step: "#profile##connect_address:")

    if message_to_update?
      update_inline_keyboard(photo: default_profile, caption: text, buttons: [back_button])
    else
      send_photo_with_keyboard(photo: default_profile, caption: text, buttons: [back_button])
    end
  end

  def connect_address
    punk_number = telegram_request.message.text.strip
    punk = Punk.find_by(number: punk_number)
    return connect_punk(I18n.t("profile.errors.punk_not_found")) unless punk

    punk_connection = user.punk_connections.create!(state: :requested, punk: punk)

    user.update!(next_step: nil)
    wait_for_transaction(punk_connection)
  end

  def disconnect_punk
    buttons = [TelegramButton.new(text: I18n.t("common.confirm"), data: "#profile##confirm:"), back_button]
    text = I18n.t("profile.labels.disconnect_punk")

    if message_to_update?
      update_inline_keyboard(photo: default_profile, caption: text, buttons: buttons)
    else
      send_photo_with_keyboard(photo: default_profile, caption: text, buttons: buttons)
    end
  end

  def confirm
    punk_connection = user.connected_punk_connection
    punk_connection.disconnected!
    PunkConnections::Disconnect.call(punk_connection: punk_connection)
    text = I18n.t("common.done")

    update_inline_keyboard(photo: default_profile, caption: text, buttons: [back_button])
  end

  def wait_for_transaction(punk_connection)
    caption = I18n.t("profile.labels.wait_for_transaction", wallet_address: wallet.pretty_address)
    Users::CheckPunkConnectionWorker.perform_async(user.id) if wallet.active? && wallet.balance.to_i > 0

    buttons = [
      [tonhub_button],
      [tonkeeper_button],
      [
        TelegramButton.new(
          text: I18n.t("common.cancel"),
          data: "#profile##cancel_connection:punk_connection_id=#{punk_connection.id}"
        ),
        back_button
      ]
    ]

    if message_to_update?
      update_inline_keyboard(photo: default_profile, caption: caption, buttons: buttons, parse_mode: "markdown")
    else
      send_photo_with_keyboard(photo: default_profile, caption: caption, buttons: buttons, parse_mode: "markdown")
    end
  end

  def cancel_connection
    PunkConnection.requested.find_by(id: callback_arguments["punk_connection_id"])&.destroy

    menu
  end

  private

  def tonhub_button
    TelegramButton.new(
      text: I18n.t("profile.labels.tonhub_connection"),
      url: "https://tonhub.com/transfer/#{wallet.pretty_address}?amount=100000000"
    )
  end

  def tonkeeper_button
    TelegramButton.new(
      text: I18n.t("profile.labels.tonkeeper_connection"),
      url: "#{IntegrationsConfig.ton_connect_url}?token=#{user.auth_token}"
    )
  end

  def default_profile
    user.profile_url
  end

  def language_button
    TelegramButton.new(text: I18n.t("profile.buttons.language"), data: "#language##menu:")
  end

  def notifications_button
    TelegramButton.new(text: I18n.t("profile.buttons.notifications"), data: "#notification##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#profile##menu:")
  end
end
