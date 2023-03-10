class Crm::Onboarding::Completed::Day4 < Crm::Onboarding::Completed::Base
  private

  def previous_notification_type
    Crm::Onboarding::Completed::Day1
  end

  def previous_notification_time_ago
    3.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.onboarding.completed.day4.text",
      button_key: "crm.onboarding.completed.day4.button",
      action: "#cyber_arena##menu:new_message=true"
    )
  end
end
