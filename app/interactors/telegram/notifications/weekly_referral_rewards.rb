class Telegram::Notifications::WeeklyReferralRewards < Telegram::Base
  def call
    caption = I18n.t("notifications.weekly_referral_rewards.caption",
      experience: user.referral_rewards.for_last_week.experience_gained,
      ton: user.referral_rewards.for_last_week.ton_gained,
      praxis: user.referral_rewards.for_last_week.praxis_gained)

    buttons = [
      [TelegramButton.new(text: I18n.t("notifications.weekly_referral_rewards.button"), data: "#invite##menu:")]
    ]

    send_inline_keyboard(text: caption, buttons: buttons, photo: photo)
  end

  def photo
    File.open(TelegramImage.path("invite.png"))
  end
end
