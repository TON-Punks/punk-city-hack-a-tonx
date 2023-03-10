class Telegram::Callback::Invite < Telegram::Callback
  delegate :wallet, to: :user

  def menu
    buttons = [
      [TelegramButton.new(text: I18n.t("invite.labels.button"), switch_inline_query: "")],
      [back_button]
    ]

    text = I18n.t("invite.labels.menu",
      referrals_count: user.referrals.count,
      experience_gained: user.referral_rewards.experience_gained,
      ton_gained: user.referral_rewards.ton_gained,
      praxis_gained: user.referral_rewards.praxis_gained
    )

    if message_to_update?
      update_inline_keyboard(photo: invite_photo, caption: text, buttons: buttons, parse_mode: nil)
    else
      send_inline_keyboard(photo: invite_photo, text: text, buttons: buttons, parse_mode: nil)
    end
  end

  private

  def invite_photo
    File.open(TelegramImage.path("invite.png"))
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#profile##menu:")
  end
end
