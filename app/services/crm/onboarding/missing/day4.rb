class Crm::Onboarding::Missing::Day4 < Crm::Onboarding::Missing::Base
  private

  def previous_notification_type
    Crm::Onboarding::Missing::Day1
  end

  def previous_notification_time_ago
    3.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.onboarding.missing.day4.text",
      button_key: "crm.onboarding.missing.day4.button",
      action: "#onboarding##step1"
    )
  end
end
