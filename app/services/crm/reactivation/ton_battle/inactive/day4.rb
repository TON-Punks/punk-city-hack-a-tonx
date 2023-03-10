class Crm::Reactivation::TonBattle::Inactive::Day4 < Crm::Reactivation::TonBattle::Inactive::Base
  private

  def previous_notification_type
    Crm::Reactivation::TonBattle::Inactive::Day1
  end

  def previous_notification_time_ago
    3.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.reactivation.ton_battle.inactive.day4.text",
      button_key: "crm.reactivation.ton_battle.inactive.day4.button",
      action: "#cyber_arena##menu:new_message=true"
    )
  end
end
