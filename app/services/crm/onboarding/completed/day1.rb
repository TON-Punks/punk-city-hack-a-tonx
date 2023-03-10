class Crm::Onboarding::Completed::Day1 < Crm::Onboarding::Completed::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.onboarding.completed.day1.text",
      button_key: "crm.onboarding.completed.day1.button",
      action: "#cyber_arena##menu:new_message=true"
    )
  end
end
