class Crm::Onboarding::Missing::Day1 < Crm::Onboarding::Missing::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.onboarding.missing.day1.text",
      button_key: "crm.onboarding.missing.day1.button",
      action: "#onboarding##step1"
    )
  end
end
