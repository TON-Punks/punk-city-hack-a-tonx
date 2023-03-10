class Crm::Arena::Regular::TopUp::Day14 < Crm::Arena::Regular::TopUp::Base
  private

  def previous_notification_type
    Crm::Arena::Regular::TopUp::Day7
  end

  def previous_notification_time_ago
    7.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.arena.regular.top_up.day14.text",
      button_key: "crm.arena.regular.top_up.day14.button",
      action: "#wallet##menu:"
    )
  end
end
