class Crm::Arena::Regular::TopUp::Day7 < Crm::Arena::Regular::TopUp::Base
  private

  def previous_notification_type
    Crm::Arena::Regular::TopUp::Day4
  end

  def previous_notification_time_ago
    3.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.arena.regular.top_up.day7.text",
      button_key: "crm.arena.regular.top_up.day7.button",
      action: "#wallet##menu:"
    )
  end
end
