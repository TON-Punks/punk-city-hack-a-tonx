class Telegram::Notifications::ConnectedPunkBonus < Telegram::Base
  delegate :connected_days,
           :praxis_reward,
           :exp_reward,
           :additional_punks_count,
           :additional_praxis_reward,
           :additional_exp_reward,
           to: :context

  def call
    send_message(
      I18n.t("notifications.connected_punk_bonus.reward",
        connected_days: DaysPassedFormatter.call(connected_days),
        praxis_reward: praxis_reward,
        exp_reward: exp_reward,
        additional_reward: additional_reward_text
      )
    )
  end

  private

  def additional_reward_text
    if additional_punks_count.positive?
      I18n.t("notifications.connected_punk_bonus.additional_punks_reward",
        punks_count: additional_punks_count,
        praxis_reward: additional_praxis_reward,
        exp_reward: additional_exp_reward
      )
    else
      ""
    end
  end
end
